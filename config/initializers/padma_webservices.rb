HYDRA = Typhoeus::Hydra.new

module Accounts
  HYDRA = ::HYDRA
  API_KEY = ENV['accounts_key']
end

module ActivityStream
  HYDRA = ::HYDRA
  API_KEY = ENV['activities_key']
  LOCAL_APP_NAME = 'crm'
end

class LogicalModel
  if Rails.env.production? || Rails.env.staging?
    def self.logger
      Logger.new(STDOUT)
    end
  end
end
