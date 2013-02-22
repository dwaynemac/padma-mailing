class TemplatesController < ApplicationController

  load_and_authorize_resource

  def index
    # @templates initialized by load_and_authorize_resource
    @account = current_user.current_account
  end

  def show
    # @template initialized by load_and_authorize_resource
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
    @template.update_attributes(params[:template])

    redirect_to @template
  end

  def deliver
    return if params[:recipient].nil?
    # Set current local variables
    template = current_user.current_account.templates.find(params[:id])
    authorize! :deliver, template
    account_email = current_user.current_account.padma.email
    to = params[:recipient]
    bcc = params[:from] || current_user.email
    from = params[:from] || account_email

    # Deliver mail
    PadmaMailer.template(template, to, bcc, from).deliver

    # Notify Activity Stream
    a = ActivityStream::Activity.new(target_id: contact_id, target_type: 'Contact',
                                     object_id: follow.id, object_type: 'Follow',
                                     generator: 'padma-mailing',
                                     verb: 'deleted',
                                     content: I18n.t('enrollment.follow_removed_due_to_enrollment',
                                                     account_name: account_name),
                                     public: false,
                                     username: follow.username,
                                     account_name: follow.account_name,
                                     created_at: Time.zone.now,
                                     updated_at: Time.zone.now
    )
    a.create(username: follow.username, account_name: follow.account_name)

    redirect_to templates_url
  end

  def destroy
    # @template initialized by load_and_authorize_resource
    @template.destroy

    redirect_to templates_url
    # render :json => "OK"
  end
end
