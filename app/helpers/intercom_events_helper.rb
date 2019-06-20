module IntercomEventsHelper

  def register_on_intercom(event_name, options={})
    intercom_options = {
      event_name: event_name,
      created_at: Time.now.to_i,
      user_id: current_user.username
    }
    if options[:metadata]
      intercom_options = intercom_options.merge({
        metadata: options[:metadata]
      })
    end
    i = intercom_client
    i.events.delay.create(intercom_options)
  rescue => e
    Rails.logger.warn "failed registering on intercom: #{e.message}"
  end

  def intercom_client
    if @intercom.nil?
      @intercom = Intercom::Client.new(token: ENV["intercom_token"])
    else
      @intercom
    end
  end
end
