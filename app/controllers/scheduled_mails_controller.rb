class ScheduledMailsController < ApplicationController

  load_and_authorize_resource

  def index
    @scheduled_mails = @scheduled_mails.includes(:template).order('send_at asc')
  end

  def destroy
    @scheduled_mail.destroy
    redirect_to scheduled_mails_path, notice: I18n.t('scheduled_mails.destroy.success')
  end

end
