if (Rails.env.staging? || Rails.env.development?) && ENV['MAILTRAP_HOST'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      :user_name => ENV['MAILTRAP_USER_NAME'],
      :password => ENV['MAILTRAP_PASSWORD'],
      :address => ENV['MAILTRAP_HOST'],
      :port => ENV['MAILTRAP_PORT'],
      :authentication => :plain,
  }
end