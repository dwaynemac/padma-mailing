HYDRA = Typhoeus::Hydra.new

CRM_HOST =case Rails.env
  when "production"
    "crm.padm.am"
  when "staging"
    "padma-crm-staging.herokuapp.com"
  when "development"
    APP_CONFIG['crm-url'].gsub("https://",'')
  when "test"
    "localhost:3000"
end

module Accounts
  HYDRA = ::HYDRA
  API_KEY = ENV['accounts_key']
  if APP_CONFIG['on-cloud9']
    HOST = APP_CONFIG['accounts-url'].gsub("http://",'')
  end
end

module Contacts
  HYDRA = ::HYDRA
  API_KEY = ENV['contacts_key']
  if Rails.env.development?
    if APP_CONFIG['on-cloud9']
      HOST = APP_CONFIG['contacts-url'].gsub("http://",'')
    else
      HOST = "localhost:3002"
    end
  end
end

module AttendanceClient
  HYDRA = ::HYDRA
  APP_KEY = ENV['attendance_key']
  if ENV['C9_USER']
    HOST = APP_CONFIG['attendance-url'].gsub(/https?:\/\//,'')
  end
end

module ActivityStream
  HYDRA = ::HYDRA
  API_KEY = ENV['activities_key']
  LOCAL_APP_NAME = 'mailing'
  if APP_CONFIG['on-cloud9']
    HOST = APP_CONFIG['activity-stream-url'].gsub("https://",'')
  end
end

class LogicalModel
  if Rails.env.production? || Rails.env.staging?
    def self.logger
      Logger.new(STDOUT)
    end
  end
end
