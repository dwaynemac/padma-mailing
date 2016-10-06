require 'rest_client'

class Mailchimp::Configuration < ActiveRecord::Base
  
  # This is a bug in Rails 3.2 that is fixed in Rails 4.0.0.
  self.table_name = 'mailchimp_configurations'
  
  attr_accessible :api_key
  attr_accessible :local_account_id
  attr_accessible :synchronizer_id
  attr_accessible :filter_method
  attr_accessor :status

  validates_presence_of :api_key
  validate :api_key_is_valid
  
  belongs_to :account, foreign_key: :local_account_id

  # List with which PADMA is synced
  attr_accessible :primary_list_id
  belongs_to :primary_list, foreign_key: :primary_list_id, class_name: 'Mailchimp::List'

  has_many :mailchimp_segments,
           through: :primary_list

  # Lists the account has in mailchimp
  has_many :mailchimp_lists,
           foreign_key: :mailchimp_configuration_id,
           class_name: "Mailchimp::List",
           dependent: :destroy
  
  before_create :create_synchronizer
  after_create :sync_mailchimp_lists_locally

  after_destroy :destroy_synchronizer
  
  # @return [Gibbon:API]
  def api
    if @mailchimp_api.nil?
      @mailchimp_api = Gibbon::API.new api_key
      @mailchimp_api.throws_exceptions = false
    end
    @mailchimp_api
  end

  def create_synchronizer
    response = Typhoeus.post Contacts::HOST + '/v0/mailchimp_synchronizers', body: {
      app_key: Contacts::API_KEY,
      account_name: account.name,
      synchronizer: {api_key: api_key}
    }
    
    if response.success?
      self.synchronizer_id = JSON.parse(response.body)['id']   
    else
      self.errors.add(:synchronizer_id, I18n.t('mailchimp_configuration.synchronizer_not_created'))
      return false
    end
  end

  def run_synchronizer
    response = Typhoeus.post Contacts::HOST + "/v0/mailchimp_synchronizers/#{self.synchronizer_id}/synchronize", body: {
      app_key: Contacts::API_KEY,
      account_name: account.name,
    }

    if response.success?
      true
    else
      false
    end
  end

  def destroy_synchronizer
    response = Typhoeus.delete Contacts::HOST + "/v0/mailchimp_synchronizers/#{self.synchronizer_id}", body: {
      app_key: Contacts::API_KEY,
      account_name: account.name,
      synchronizer: {api_key: api_key}
    }
  end
  
  def update_synchronizer
    response = RestClient.put Contacts::HOST + '/v0/mailchimp_synchronizers/' + self.synchronizer_id.to_s,
      id: synchronizer_id,
      app_key: Contacts::API_KEY,
      account_name: account.name,
      synchronizer: {
        api_key: api_key,
        list_id: primary_list.api_id,
        filter_method: filter_method,
        contact_attributes: primary_list.contact_attributes 
      }
  end
  
  def sync_mailchimp_lists_locally
    self.mailchimp_lists.destroy_all
    api.lists.list['data'].each do |list_hash|
      Mailchimp::List.create(
        api_id: list_hash['id'],
        name: list_hash['name'],
        mailchimp_configuration_id: id
      )
    end
  end

  def api_key_is_valid
    return if api_key.blank?

    begin
      if api.lists.list['data'].nil?
        self.errors.add(:api_key, I18n.t('mailchimp_configuration.api_key_is_not_valid'))
      end
    rescue OpenSSL::SSL::SSLError
      self.errors.add(:api_key, I18n.t('mailchimp_configuration.api_key_is_not_valid'))
    end
  end

end
