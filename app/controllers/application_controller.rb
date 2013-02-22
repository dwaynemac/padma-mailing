class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :mock_login
  before_filter :authenticate_user!
  before_filter :require_padma_account
  before_filter :set_current_account


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
    if Rails.env.development?
      user = User.find_or_create_by_username("mocked.user")
      sign_in(user)
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

  def set_current_account
    if signed_in? && current_user.padma_enabled?
      current_user.current_account = Account.find_or_create_by_name(current_user.padma.enabled_accounts.first.name)
    end
  end
end
