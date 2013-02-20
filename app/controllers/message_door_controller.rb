class MessageDoorController < ApplicationController

  # @argument key_name [String]
  # @argument data [Hash]
  # @argument secret_key [String]
  def catch
    if params[:secret_key] == ENV['messaging_secret']
      Trigger.catch_message(params[:key_name],params[:data])
      render text: 'received', status: 200
    else
      render text: 'wrong secret_key', status: 403
    end
  end

end
