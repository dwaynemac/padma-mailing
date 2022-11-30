class Api::V0::TemplatesController < Api::V0::ApiController
  respond_to :json
  before_filter :set_scope, only: [:index]

  def index
    if params[:where]
      if @scope.empty?
        @templates = []
      else
        @templates = @scope.where(where_params)
      end
    else
      @templates = @scope
    end
    respond_with @templates do |format|
      format.json { render :json => { :collection => @templates, :total => @templates.count }.as_json }
    end
  end

  def show
    template = Template.find(params[:id])
    respond_to do |format|
      format.json { render :json => template.as_json }
    end
  end

  def attachments
    template = Template.find(params[:id])
    respond_to do |format|
      format.json { render json: { collection: template.attachments.map{|a| a.attachment.url}, total: template.attachments.count }.as_json }
    end
  end

  private

    def set_scope
      @scope = if params[:account_id]
        local_account = Account.where(name: params[:account_id])
        local_account.empty? ? [] : Template.where(local_account_id: local_account.first.id)
      else
        Template
      end
    end

    def where_params
      params.require(:where).permit!
    end
end
