class TriggersController < ApplicationController

  load_and_authorize_resource

  def index

  end

  def new

  end

  def create
    @trigger.save!
    render text: 'created'
  end

end
