module ApplicationHelper

  def petal_enabled?(petal_name)
    petal_name.in?(current_user.current_account.padma.enabled_petals)
  end

  def generate_secure_doorbell_signature()
      jsonp_secret = ENV['doorbellio_key']
      timestamp = Time.now.to_i
      token = SecureRandom.hex(50)

      signature = OpenSSL::HMAC.hexdigest(
                  OpenSSL::Digest::Digest.new('sha256'),
                  jsonp_secret,
                  '%s%s' % [timestamp, token])

      return "timestamp: #{timestamp}, token: '#{token}', signature: '#{signature}', ".html_safe
  end

  def breadcrum(text)
    content_for :breadcrum, text
  end

  def page_title(title)
    content_for :page_title, title
  end
end
