class Mailchimp::Configuration < ActiveRecord::Base
  attr_accessible :api_key
  attr_accessible :local_account_id
  attr_accessible :primary_list_id
  
  belongs_to :account, foreign_key: :local_account_id
  has_many :lists
  
  # @return [Gibbon:API]
  def api
    if @mailchimp_api.nil?
      @mailchimp_api = Gibbon::API.new api_key
      @mailchimp_api.throws_exceptions = false
    end
    @mailchimp_api
  end

  def primary_list
    List.find(primary_list_id) 
  end

end
