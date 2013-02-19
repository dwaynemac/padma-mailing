class TemplatesController < ApplicationController

  load_and_authorize_resource

  def index
    # @templates initialized by load_and_authorize_resource
    @account = current_user.current_account

    # response.headers['Content-type'] = 'application/json; charset=utf-8'
    # render :json => { :collection => @templates, :total => total}.as_json(account: @account, except_linked:true, except_last_local_status: true)
  end

  def show
    # @template initialized by load_and_authorize_resource
    @account = current_user.current_account

    # render :json => @template.as_json(:account => @account, :include_masked => true)
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
    # render :json => { :id => @template.id }.to_json, :status => :created
  end

  def update
    # @template initialized by load_and_authorize_resource
    @template.update_attributes(params[:template])

    redirect_to @template
    # render :json => "OK"
  end

  def deliver
    return if params[:recipient].nil?
    account_email = PadmaAccount.find(current_user.current_account.name).email
    template = current_user.current_account.templates.find(params[:id])
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
