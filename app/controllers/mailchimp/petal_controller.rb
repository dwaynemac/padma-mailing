class Mailchimp::PetalController < ApplicationController
  include Mailchimp::SubscriptionsHelper

  before_filter :check_petal_enabled

  private
  
  def check_petal_enabled
    unless mailchimp_enabled?
      redirect_to new_subscriptions_mailchimp_path
    end
  end

end
