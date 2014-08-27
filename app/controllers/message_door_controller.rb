class MessageDoorController < ApplicationController

  skip_before_filter :mock_login
  skip_before_filter :authenticate_user!
  skip_before_filter :require_padma_account
  skip_before_filter :set_current_account

  ##
  #
  # Valid Key Names: communication, subcription_change, trial_lesson, birthday @see Trigger::VALID_EVENT_NAMES
  # Global Key Names: birthday @see Trigger::GLOBAL_EVENTS
  #
  # data MUST include :account_name key EXCEPT for Global Key Names.
  #
  # @argument key_name [String]
  # @argument data [String] JSON encoded
  # @argument secret_key [String]
  def catch
    if params[:secret_key] == ENV['messaging_secret']
      Trigger.catch_message(params[:key_name],
                            ActiveSupport::JSON.decode(params[:data]))
      render text: 'received', status: 200
    else
      render text: 'wrong secret_key', status: 403
    end
  end

end
