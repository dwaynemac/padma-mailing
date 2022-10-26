class Api::V0::ScheduledMailsController < Api::V0::ApiController
  respond_to :json
  before_filter :set_scope, only: [:index]

  def index
    if params[:where]
      if @scope.empty?
        scheduled_mails = []
      else
        scheduled_mails = @scope.where(where_params)
      end
    else
      scheduled_mails = @scope
    end
    respond_with scheduled_mails do |format|
      format.json { render :json => { :collection => scheduled_mails, :total => scheduled_mails.count }.as_json }
    end
  end

  def show
    scheduled_mail = ScheduledMail.find(params[:id])
    respond_to do |format|
      format.json { render :json => scheduled_mail.as_json }
    end
  end

  private

    def set_scope
      @scope = if params[:account_id]
        local_account = Account.where(name: params[:account_id])
        local_account.empty? ? [] : ScheduledMail.where(local_account_id: local_account.first.id)
      else
        ScheduledMail.scoped
      end
    end

    def where_params
      params.require(:where).permit!
    end
end
