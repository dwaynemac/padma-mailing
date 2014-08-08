class Mailchimp::Configuration < ActiveRecord::Base
  
  # This is a bug in Rails 3.2 that is fixed in Rails 4.0.0.
  self.table_name = 'mailchimp_configurations'
  
  attr_accessible :api_key
  attr_accessible :local_account_id
  attr_accessible :primary_list_id
  
  belongs_to :account, foreign_key: :local_account_id
  has_many :mailchimp_lists, foreign_key: :mailchimp_configuration_id, class_name: "Mailchimp::List"
  
  after_create :create_lists_in_mailchimp
  after_create :create_contacts_synchronizer
  
  # @return [Gibbon:API]
  def api
    if @mailchimp_api.nil?
      @mailchimp_api = Gibbon::API.new api_key
      @mailchimp_api.throws_exceptions = false
    end
    @mailchimp_api
  end

  def primary_list
    Mailchimp::List.find(primary_list_id) 
  end

  def create_contacts_synchronizer
    debugger
    list = primary_list

    response = RestClient.post Contacts::HOST + '/v0/mailchimp_synchronizers',
      app_key: Contacts::API_KEY,
      account_name: account.name,
      synchronizer: {
        api_key: api_key,
        list_id: primary_list_id,
      }
    
    puts response
  end
  
  private
  
  def create_lists_in_mailchimp
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
