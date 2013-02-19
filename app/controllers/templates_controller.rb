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
    template = current_user.current_account.templates.find(params[:id])
    authorize! :deliver, template
    account_email = current_user.current_account.padma.email
    to = params[:recipient]
    bcc = params[:from] || current_user.email
    from = params[:from] || account_email
    PadmaMailer.template(template, to, bcc, from).deliver

    redirect_to templates_url
  end

  def destroy
    # @template initialized by load_and_authorize_resource
    @template.destroy

    redirect_to templates_url
    # render :json => "OK"
  end
end
