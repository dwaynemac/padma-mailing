class Mailchimp < ActiveRecord::Base
  attr_accessible :api_key
  attr_accessible :list
  belongs_to :account, foreign_key: :local_account_id
  
  # @return [Gibbon:API]
  def api
    if @mailchimp_api.nil?
      @mailchimp_api = Gibbon::API.new api_key
      @mailchimp_api.throws_exceptions = false
    end
    @mailchimp_api
  end

end
