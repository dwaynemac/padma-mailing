class TriggersController < ApplicationController
  before_action :get_trigger, only: [:create]

  load_and_authorize_resource except: [:create]
  authorize_resource only: [:create]

  def index

  end

  def new

  end

  def create
    @trigger.save!
    redirect_to triggers_url
  end

  def destroy
    @trigger.destroy
    redirect_to triggers_url
  end

  private

  def trigger_params
    params.require(:trigger).permit!
  end

  def get_trigger
    @trigger = Trigger.new(trigger_params)
    @trigger.local_account_id = current_user.current_account.id
  end
end
