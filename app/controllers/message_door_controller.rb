class MessageDoorController < ApplicationController

  # @argument key_name [String]
  # @argument data [String] JSON encoded
  # @argument secret_key [String]
  def catch
    if params[:secret_key] == ENV['messaging_secret']
      Trigger.catch_message(params[:key_name],ActiveSupport::JSON.decode(params[:data]))
      render text: 'received', status: 200
    else
      render text: 'wrong secret_key', status: 403
    end
  end

end
