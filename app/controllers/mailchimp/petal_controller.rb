class Mailchimp::PetalController < ApplicationController
  include ApplicationHelper

  before_filter :check_petal_enabled, except: [:subscribe]

  def subscribe
  end

  private
  
  def check_petal_enabled
    unless petal_enabled?('mailchimp')
      redirect_to subscribe_mailchimp_petal_path
    end
  end

end
