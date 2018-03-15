class Mailchimp::List < ActiveRecord::Base
  attr_accessible :api_id
  attr_accessible :mailchimp_configuration_id
  attr_accessible :name
  attr_accessible :mailchimp_segments_attributes
  attr_accessible :contact_attributes
  
  belongs_to :mailchimp_configuration, foreign_key: :mailchimp_configuration_id, class_name: "Mailchimp::Configuration" 

  has_many :mailchimp_segments,
           foreign_key: :mailchimp_list_id,
           class_name: "Mailchimp::Segment",
           dependent: :destroy
  
  accepts_nested_attributes_for :mailchimp_segments,
    allow_destroy: true,
    reject_if: proc { |attr|
      !Mailchimp::Segment.new(attr).valid?
    }

  def primary?
    self.id == self.mailchimp_configuration.primary_list_id
  end

  def get_scope(page = 1, per = 25)
    resp = Typhoeus.get Contacts::HOST + "/v0/mailchimp_synchronizers/get_scope", body: {
      app_key: ENV["contacts_key"],
      api_key: mailchimp_configuration.api_key,
      preview: false,
      page: page,
      per: per
    }
    JSON.parse(resp.body)
  end

  def remote_list
    get_api
    @api.lists(api_id).retrieve.body
  end

  def batches
    get_api
    @api.batches.retrieve.body["batches"]
  end

  def unsubscribed
    get_api
    begin
      @api.lists(api_id).members.retrieve(
        params: {
          status: "unsubscribed",
          fields: "members.merge_fields,,e,bers.email.address"
        }
      ).body["members"]
    rescue Gibbon::MailChimpError
      return nil #TODO show error
    end
  end

  def cleaned
    get_api
    begin
      @api.lists(api_id).members.retrieve(
        params: {
          status: "cleaned", 
          fields: "members.merge_fields,members.email_address"
        }
      ).body["members"]
    rescue Gibbon::MailChimpError
      return nil #TODO show error
    end
  end
  
  def member(email)
    get_api
    begin
      @api.lists(api_id).members(subscriber_hash(email)).retrieve(
        params: {fields: "status,merge_fields"}
      ).body
    rescue Gibbon::MailChimpError
      return nil #TODO show error
    end
  end

  def remove_member(email)
    get_api
    return nil if email.blank?
    
    begin
      @api.lists(api_id).members(subscriber_hash(email)).delete
    rescue Gibbon::MailChimpError => e
      return {status: false, message: e.message}
    end

    {status: true}
  end

  private
  
  def get_api
    @api = @api || Gibbon::Request.new(api_key: mailchimp_configuration.api_key)  
  end

  def subscriber_hash(email)
    Digest::MD5.hexdigest(email.downcase) unless email.nil?
  end
end
