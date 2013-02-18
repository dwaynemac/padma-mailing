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
    puts "ENTRE A DELIVER TEMPLATE, con el id: #{params.inspect}"
    #return if params[:template].nil?
    template = current_user.current_account.templates.find(params[:id])
    to = "ailen.iglesias@gmail.com" #params[:model][:recipient]
    #bcc = params[:model][:from] || current_user.email
    from = "afalkear@gmail.com" #params[:model][:from]
    puts "A PUNTO DE MANDAR MAIL"
    PadmaMailer.mail_template(template, to, nil, from).deliver
    puts "MANDO MAIL, AHORA DEBERIA REDIRIGIR"
    redirect_to @template
  end

  def destroy
    # @template initialized by load_and_authorize_resource
    @template.destroy

    redirect_to templates_url
    # render :json => "OK"
  end
end
