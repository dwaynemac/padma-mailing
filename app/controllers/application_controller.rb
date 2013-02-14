class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :mock_login
  before_filter :authenticate_user!
  before_filter :require_padma_account

  def home
    msg = "welcome home #{current_user.username}"
    msg << "\n#{Accounts::API_KEY}"
    render text: msg
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

  private

  # Mocks CAS login in development
  def mock_login
    def mock_login
      if Rails.env.development?
          user = User.find_or_create_by_username("mocked.user")
          sign_in(user)
      end
    end
  end

  # CAS user must have a PADMA account
  def require_padma_account
    if signed_in?
      unless current_user.padma_enabled?
        render text: 'Access allowed to PADMA users only - Think this is a mistake? Maybe PADMA Authentication service is down.'
      end
    end
  end

end
