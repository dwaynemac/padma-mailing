require 'rest_client'

class Mailchimp::Configuration < ActiveRecord::Base
  
  # This is a bug in Rails 3.2 that is fixed in Rails 4.0.0.
  self.table_name = 'mailchimp_configurations'
  
  attr_accessible :api_key
  attr_accessible :local_account_id
  attr_accessible :primary_list_id
  attr_accessible :synchronizer_id
  attr_accessible :filter_method
  
  belongs_to :account, foreign_key: :local_account_id
  has_many :mailchimp_lists, foreign_key: :mailchimp_configuration_id, class_name: "Mailchimp::List"
  
  before_create :create_synchronizer
  after_create :create_mailchimp_lists_locally
  
  # @return [Gibbon:API]
  def api
    if @mailchimp_api.nil?
      @mailchimp_api = Gibbon::API.new api_key
      @mailchimp_api.throws_exceptions = false
    end
    @mailchimp_api
  end

  def create_synchronizer
    response = RestClient.post Contacts::HOST + '/v0/mailchimp_synchronizers',
      app_key: Contacts::API_KEY,
      account_name: account.name,
      synchronizer: {api_key: api_key}
    
    self.synchronizer_id = JSON.parse(response)['id']   
  end
  
  def primary_list
    Mailchimp::List.find(primary_list_id)
  end
  
  def update_synchronizer
    response = RestClient.put Contacts::HOST + '/v0/mailchimp_synchronizers/' + self.synchronizer_id.to_s,
      id: synchronizer_id,
      app_key: Contacts::API_KEY,
      account_name: account.name,
      synchronizer: {
        api_key: api_key,
        list_id: primary_list.api_id,
        filter_method: filter_method 
      }
  end
  
  private
  
  def create_mailchimp_lists_locally
    api.lists.list['data'].each do |list_hash|
      if Mailchimp::List.where(api_id: list_hash['id']).empty?    
        Mailchimp::List.create(
          api_id: list_hash['id'],
          name: list_hash['name'],
          mailchimp_configuration_id: id
        )
      end
    end
  end

end
