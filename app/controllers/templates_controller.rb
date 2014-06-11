class TemplatesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  load_and_authorize_resource
  before_filter :modified_mercury_editor_tag_text, only: [:mercury_create, :mercury_update]

  def index
    # @templates initialized by load_and_authorize_resource

    @account = current_user.current_account

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
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  def edit
    @initialize_tags = mercury_tags_json
    # @template initialized by load_and_authorize_resource
  end

  def create
    # @template initialized by load_and_authorize_resource
    @template.update_attribute("local_account_id", current_user.current_account.id)
    @template.save!

    redirect_to @template
  end

  def update
    # @template initialized by load_and_authorize_resource
    @template.attachments.create(params[:template][:attachment])
    params[:template].delete :attachment
    @template.update_attributes(params[:template])

    respond_to do |format|
      format.html { redirect_to @template }
      format.js
    end
  end

  def deliver
    return if params[:recipient].nil?
    # Set current local variables
    template = current_user.current_account.templates.find(params[:id])
    authorize! :deliver, template

    data = {to: params[:recipient], user: current_user, contact_id: params[:contact_id]}

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

  def modified_mercury_editor_tag_text
    doc = Nokogiri::HTML::DocumentFragment.parse(params[:content][:template_content][:value])
    divs = doc.css('div')
    divs.each do |div|
      snippet = div.attributes["data-snippet"].try(:value)
      return unless snippet
      new_snippet_value = params[:content][:template_content][:snippets][snippet].values.last rescue nil
      return unless new_snippet_value
      div.content = new_snippet_value
    end
    params[:content][:template_content][:value] = doc.inner_html
  end

  def mercury_tags_json
    hash = {}
    doc = Nokogiri::HTML::DocumentFragment.parse(@template.content)
    divs = doc.css('div')
    divs.each do |div|
      name = div.attributes["class"].value.split("-snippet").first
      hash.merge!("#{div.attributes["data-snippet"].value}"=>{name: name, 
                  options: tag_options_hash(name)
                }
      )
    end
    hash.to_json
  end

  def tag_options_hash(name)
    case name
    when "time_slot"
      {"Name"=> "%{time_slot.name}"}
    when "contact"
      {"Full Name" => "%{contact.full_name}%"}
    when "instructor"
      {"Name" => "%{instructor.name}"}
    when "trial_lesson"
      {"Date" => "%{trial_lesson.date}"}
    end
  end

end
