class TemplatesController < ApplicationController
  def index
    @templates = Template.all
    @account = current_user.current_account

    # response.headers['Content-type'] = 'application/json; charset=utf-8'
    # render :json => { :collection => @templates, :total => total}.as_json(account: @account, except_linked:true, except_last_local_status: true)
  end

  def show
    @template = Template.find(params[:id])
    @account = current_user.current_account

    # render :json => @template.as_json(:account => @account, :include_masked => true)
  end

  def new
    @template = Template.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  def edit
    @template = Template.find(params[:id])
  end

  def create
    @template = Template.new(params[:template])
    @template.update_attribute("local_account_id", current_user.current_account.id)
    @template.save!

    redirect_to @template
    # render :json => { :id => @template.id }.to_json, :status => :created
  end

  def update
    @template = Template.find(params[:id])
    @template.update_attributes(params[:template])

    redirect_to @template
    # render :json => "OK"
  end

  def destroy
    @template = Template.find(params[:id])
    @template.destroy

    redirect_to templates_url
    # render :json => "OK"
  end
end
