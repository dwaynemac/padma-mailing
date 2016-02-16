class Mailchimp::PetalController < ApplicationController
  include ApplicationHelper
  before_filter :check_petal_enabled, except: [:integration]

  private
  
  def check_petal_enabled
    unless petal_enabled?('mailchimp')
      redirect_to integration_mailchimp_configuration_path
    end
  end

end
