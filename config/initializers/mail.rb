if (Rails.env.staging? || Rails.env.development?) && ENV['MAILTRAP_HOST'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      :user_name => ENV['MAILTRAP_USER_NAME'],
      :password => ENV['MAILTRAP_PASSWORD'],
      :address => ENV['MAILTRAP_HOST'],
      :port => ENV['MAILTRAP_PORT'],
      :authentication => :plain,
  }
elsif(Rails.env.production?)
  ActionMailer::Base.smtp_settings = {
      :address        => 'smtp.sendgrid.net',
      :port           => '587',
      :authentication => :plain,
      :user_name      => ENV['SENDGRID_USERNAME'],
      :password       => ENV['SENDGRID_PASSWORD'],
      :domain         => 'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp
end