class Mailchimp::Configuration < ActiveRecord::Base
  
  # This is a bug in Rails 3.2 that is fixed in Rails 4.0.0.
  self.table_name = 'mailchimp_configurations'
  
  attr_accessible :api_key
  attr_accessible :local_account_id
  attr_accessible :primary_list_id
  
  belongs_to :account, foreign_key: :local_account_id
  has_many :lists
  
  after_create :sync_lists
  
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
  
  private
  
  def sync_lists
    api.lists.list['data'].each do |list_hash|
      if List.where(api_id: list_hash['id']).empty?    
        List.create(
          api_id: list_hash['id'],
          name: list_hash['name'],
          mailchimp_configuration_id: id
        )
      end
    end
  end

end
