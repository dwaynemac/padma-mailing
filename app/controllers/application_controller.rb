class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  def home
    render text: 'welcome home'
  end

  rescue_from CanCan::AccessDenied do
    msg = "AccessDenied"
    if current_user
      msg << " for #{current_user.username}"
      if current_user.padma.try :current_account_name
        msg << " on #{current_user.padma.current_account_name}"
      end
    end
    render text: msg, status: 403
  end

end
