class TriggersController < ApplicationController

  load_and_authorize_resource

  def index

  end

  def new

  end

  def create
    @trigger.save!
    redirect_to triggers_url
  end

end
