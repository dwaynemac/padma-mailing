class ScheduledMailsController < ApplicationController

  load_and_authorize_resource

  def index
    @scheduled_mails = @scheduled_mails.includes(:template)
  end

end
