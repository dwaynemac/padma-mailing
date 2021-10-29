class TemplatesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_filter :load_template, only: [:create]
  load_and_authorize_resource
  before_filter :modified_mercury_editor_tag_text, only: [:mercury_create, :mercury_update]

  def index
    # @templates initialized by load_and_authorize_resource

    @account   = current_user.current_account

    @current_folder = @account.templates_folders.find(params[:folder_id]) if params[:folder_id]
    @templates = @templates.for_folder(params[:folder_id])
    @folders   = @account.templates_folders.for_folder(params[:folder_id])

    if params[:contact_id]
      @contact = PadmaContact.find(params[:contact_id],
                                   select: [:first_name, :last_name, :email],
                                   account_name: @account.name,
                                   username: current_user.username)
    end
  end

  def show
    # @template initialized by load_and_authorize_resource
    @attachment = @template.attachments.build
    @account = current_user.current_account
  end

  def new
    # @template initialized by load_and_authorize_resource

    respond_to do |format|
      format.html { render layout: "quill" }
    end
  end

  def new_html
    @template = Template.new()
    @template.local_account_id = current_user.current_account.id
  end

  def edit
    # @template initialized by load_and_authorize_resource

    # if @template.content has tags that are not supported by quill editor
    if has_unsupported_quill_tags?(@template.content)
      # render edit_html
      flash[:notice] = I18n.t('templates.quill.html.redirected_to_html_editor')
      redirect_to edit_html_template_path(id: @template.id)
    else
      # else render quill editor
      render layout: "quill"
    end
  end

  def edit_html

  end

  def create
    # @template initialized by load_and_authorize_resource
    @template.update_attribute("local_account_id", current_user.current_account.id)
    @template.save!

    redirect_to @template
  end

  def update
    @template = Template.find params[:id]
    # @template initialized by load_and_authorize_resource
    if params[:template].has_key?(:attachment)
      debugger
      @attachment = @template.attachments.new(template_params)
      params[:template].delete :attachment
    end

    rt = if params[:back_to]
      params[:back_to]
    elsif params[:template][:parent_templates_folder_id]
      templates_path(folder_id: params[:template][:parent_templates_folder_id])
    else
      @template
    end

    if @template.update_attributes(template_params)
      respond_to do |format|
        format.html { redirect_to rt }
        format.js
      end
    elsif !@attachment.valid?
      respond_to do |format|
        format.json do
          render json: "#{I18n.t('templates.show.attachment')} 
                    #{@attachment.errors.messages[:attachment][0]}",
                 status: 422
        end
      end
    else
      redirect_to templates_path, notice: @template.errors.full_messages
    end
  end

  def deliver
    return if params[:recipient].nil?
    # Set current local variables
    template = current_user.current_account.templates.find(params[:id])
    authorize! :deliver, template

    data = {to: params[:recipient],
            user: current_user,
            contact_id: params[:contact_id]}

    # Deliver mail and notify activities
    template.deliver(data)

    redirect_to templates_url, notice: I18n.t('templates.deliver.success')
  end

  def destroy
    # @template initialized by load_and_authorize_resource
    @template.destroy

    redirect_to templates_url
    # render :json => "OK"
  end

  def mercury_create
    name = strip_tags(params[:content][:template_name][:value]).gsub(/&nbsp;/i, "")
    description = strip_tags(params[:content][:template_description][:value]).gsub(/&nbsp;/i, "")
    subject = strip_tags(params[:content][:template_subject][:value]).gsub(/&nbsp;/i, "")
    content = params[:content][:template_content][:value]
    attachments = params[:content][:attachments]

    @template = Template.new(name: name, description: description, subject: subject, content: content)
    @template.account = current_user.current_account
    @template.save!

    render text: ""
  end

  def mercury_update
    @template.update_attributes(
        name: strip_tags(params[:content][:template_name][:value]).gsub(/&nbsp;/i, ""),
        description: strip_tags(params[:content][:template_description][:value]).gsub(/&nbsp;/i, ""),
        subject: strip_tags(params[:content][:template_subject][:value]).gsub(/&nbsp;/i, ""),
        content: params[:content][:template_content][:value]
    )

    render text: ""
  end

  private

  def has_unsupported_quill_tags?(content)
    unsupported = false
    %w(<html <table <xml <title).each do |ut|
      if content.match?(/#{ut}/)
        unsupported = true
        break
      end
    end
    return unsupported
  end

  def modified_mercury_editor_tag_text
    doc = Nokogiri::HTML::DocumentFragment.parse(params[:content][:template_content][:value])
    divs = doc.css('div')
    divs.each do |div|
      snippet = div.attributes["data-snippet"].try(:value)
      next if snippet.nil?
      new_snippet_value = params[:content][:template_content][:snippets][snippet].values.last rescue nil
      next if new_snippet_value.nil?
      new_snippet_value = new_snippet_value.values.last if new_snippet_value.is_a? Hash
      div.content = Template.convert_tag_into_liquid_format(new_snippet_value)
    end
    params[:content][:template_content][:value] = doc.inner_html
  end

  def mercury_tags_json
    hash = {}
    doc = Nokogiri::HTML::DocumentFragment.parse(@template.content)
    divs = doc.css('div')
    divs.each do |div|
      name = div.attributes["class"].value.split("-snippet").first rescue nil
      next if name.nil?

      next if div.attributes["data-snippet"].nil?
      hash.merge!(div.attributes["data-snippet"].value =>{name: name, 
                  options: tag_options_hash(name)
                }
      )
      div.content = Template.convert_tag_into_liquid_format(div.text, false)
    end
    @template.content = doc.to_s
    hash.to_json
  end

  def tag_options_hash(name)
    case name
    when "time_slot"
      {"Name"=> "[Time Slot's Name]"}
    when "contact"
      {"Full Name" => "[Contact's Full Name]"}
    when "instructor"
      {"Name" => "[Instructor's Name]"}
    when "trial_lesson"
      {"Date" => "[Trial Lesson's Date]"}
    end
  end

  def load_template
    @template = Template.new(template_params)
    @template.local_account_id = current_user.current_account.id
  end

  def template_params
    params.require(:template).permit!#(
      #:content,
      #:description,
      #:name,
      #:subject,
      #:attachments_attributes,
      #:parent_templates_folder_id,
      #:attachment
    #)
  end
end
