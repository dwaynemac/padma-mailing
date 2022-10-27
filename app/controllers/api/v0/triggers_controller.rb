class Api::V0::TriggersController < Api::V0::ApiController
  respond_to :json
  before_filter :set_scope, only: [:index]
  before_filter :set_trigger, only: [:show, :templates_triggerses, :filters, :conditions]

  def index
    if params[:where]
      if @scope.empty?
        triggers = []
      else
        triggers = @scope.where(where_params)
      end
    else
      triggers = @scope
    end
    respond_with triggers do |format|
      format.json { render :json => { :collection => triggers, :total => triggers.count }.as_json }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @trigger.as_json }
    end
  end

  def templates_triggerses
    res = @trigger.templates_triggerses
    respond_to do |format|
      format.json { render json: { collection: res, total: res.count }.as_json }
    end
  end

  def filters
    res = @trigger.filters
    respond_to do |format|
      format.json { render json: { collection: res, total: res.count }.as_json }
    end
  end

  def conditions 
    res = @trigger.conditions
    respond_to do |format|
      format.json { render json: { collection: res, total: res.count }.as_json }
    end
  end

  private

    def set_scope
      @scope = if params[:account_id]
        local_account = Account.where(name: params[:account_id])
        local_account.empty? ? [] : Trigger.where(local_account_id: local_account.first.id)
      else
        Trigger
      end
    end

    def set_trigger
      @trigger = Trigger.find(params[:id])
    end

    def where_params
      params.require(:where).permit!
    end
end
