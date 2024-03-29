class MessageDoorController < ActionController::Base
  include SnsHelper
  include SsoSessionsHelper

  def sns
    case sns_type
    when 'SubscriptionConfirmation'
      # confirm subscription to Topic
      render json: Typhoeus.get(sns_data[:SubscribeURL]).body, status: 200
    when 'Notification'
      if sns_verified?
        if sns_duplicate_submission?
          render json: 'duplicate', status: 200
        else
          case sns_topic
          when "sso_session_destroyed"
            set_sso_session_destroyed_flag(sns_message[:username])
          else
            Trigger.delay.catch_message(sns_topic,sns_message.stringify_keys!)
          end
          
          sns_set_as_received!
          render json: "received", status: 200
        end
      else
        render json: 'unverified', status: 403
      end
    else
      render json: 'WTF', status: 400
    end
  end


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
      Trigger.delay.catch_message(params[:key_name],
                                  ActiveSupport::JSON.decode(params[:data]))
      render text: 'received', status: 200
    else
      render text: 'wrong secret_key', status: 403
    end
  end

  def ping
    render text: "i'm online", status: 200
  end

end
