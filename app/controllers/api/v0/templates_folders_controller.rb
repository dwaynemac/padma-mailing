class Api::V0::TemplatesFoldersController < Api::V0::ApiController
  respond_to :json
  before_filter :set_scope, only: [:index]

  def index
    if params[:where]
      if @scope.empty?
        @templates_folders = []
      else
        @templates_folders = @scope.where(where_params)
      end
    else
      @templates_folders = @scope
    end
    respond_with @templates_folders do |format|
      format.json { render :json => { :collection => @templates_folders, :total => @templates_folders.count }.as_json }
    end
  end

  def show
    folder = TemplatesFolder.find params[:id]
    respond_to do |format|
      format.json { render json: folder.as_json }
    end
  end

  private
    def set_scope
      @scope = if params[:account_id]
        local_account = Account.where(name: params[:account_id])
        local_account.empty? ? [] : TemplatesFolder.where(local_account_id: local_account.first.id)
      else
        TemplatesFolder
      end
    end

    def where_params
      params.require(:where).permit!
    end
end
