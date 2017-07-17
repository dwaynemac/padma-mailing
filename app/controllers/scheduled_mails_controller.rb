class ScheduledMailsController < ApplicationController

  load_and_authorize_resource

  def index
    @scheduled_mails = @scheduled_mails.where("send_at > ?",1.year.ago).includes(:template, :account).order('send_at desc').page(params[:page])
    if params[:only_history]
      @scheduled_mails = @scheduled_mails.delivered
    elsif params[:only_pending]
      @scheduled_mails = @scheduled_mails.pending
    end
  end

  def destroy
    @scheduled_mail.destroy
    redirect_to scheduled_mails_path, notice: I18n.t('scheduled_mails.destroy.success')
  end

end
