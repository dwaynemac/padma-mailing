class Api::V0::ScheduledMailsController < Api::V0::ApiController

  respond_to :json
  before_filter :set_scope

  def index
    if params[:where]
      # Sets delivered_at as nil if it is send as an empty string
      params[:where][:delivered_at] = nil if params[:where][:delivered_at].blank?

      if @scope.empty?
        @scheduled_mails = []
      else
        @scheduled_mails = @scope.where(where_params)
      end
    else
      @scheduled_mails = @scope
    end
    respond_with @scheduled_mails do |format|
      format.json { render :json => { :collection => @scheduled_mails, :total => @scheduled_mails.count }.as_json }
    end
  end

  private
    # Sets the scope
    def set_scope
      @scope = if params[:account_name]
        local_account = Account.where(name: params[:account_name])
        local_account.empty? ? [] : ScheduledMail.where(local_account_id: local_account.first.id)
      else
        ScheduledMail
      end
    end

    def where_params
      params.require(:where).permit!
    end
end
