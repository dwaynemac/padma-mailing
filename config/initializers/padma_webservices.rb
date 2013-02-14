HYDRA = Typhoeus::Hydra.new

module Accounts
  HYDRA = ::HYDRA
  API_KEY = ENV['accounts_key']
end

module ActivityStream
  HYDRA = ::HYDRA
  API_KEY = "6d1a2dd931ef48d5f0c4d62de773825d3369ab426811c79c55e40569bc7bf044a437bbf569f765e6fd3a282ab43a27a2cb48ee2bd08c8bf743190165cd2ecb76"
  LOCAL_APP_NAME = 'crm'
end

class LogicalModel
  if Rails.env.production? || Rails.env.staging?
    def self.logger
      Logger.new(STDOUT)
    end
  end
end
