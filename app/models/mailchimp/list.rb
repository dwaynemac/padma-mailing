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

  def create_activity(params)
    type = params["type"]
    
    case type
    when "subscribe"
      contact_id = PadmaContact.search(
        where: {
          email: params["data"]["email"]
        },
        account_name: mailchimp_configuration.account.name,
        select: [:id]
      ).first.try :id

      message = "Has been subscribed to list: #{name}"
      
      subscription_change(message,contact_id)
    when "unsubscribe"
      contact_id = PadmaContact.search(
        where: {
          email: params["data"]["email"]
        },
        account_name: mailchimp_configuration.account.name,
        select: [:id]
      ).first.try :id
      
      message = "Has been "
      if params["data"]["action"] == "unsub"
        message << "unsubscribed"
      else
        message << "deleted"
      end
      message << " from list: #{name}"

      if params["data"]["reason"] == "abuse"
        message << "marking as a spam complaint"
      end

      #TODO add who unsubscribed "sources"
      
      subscription_change(message, contact_id)
    when "campaign"
      inform_camp
    end
  end

  def subscription_change(message, contact_id)
    ActivityStream::Activity.new(
      target_id: contact_id,
      target_type: 'Contact',
      object_id: id,
      object_type: 'Mailchimp::List',
      generator: ActivityStream::LOCAL_APP_NAME,
      content: message,
      public: false,
      username: "Mailing system",
      account_name: mailchimp_configuration.account.name,
      created_at: Time.zone.now.to_s,
      updated_at: Time.zone.now.to_s
    )
  end

  def campaign(campaign_name, contact_id)
    ActivityStream::Activity.new(
      object_type: 'Mailchimp::List',
      generator: ActivityStream::LOCAL_APP_NAME,
      content: "List #{name}: campaign #{campagin_name} has been sent",
      public: false,
      username: "Mailing system",
      account_name: mailchimp_configuration.account.name,
      created_at: Time.zone.now.to_s,
      updated_at: Time.zone.now.to_s
    )
  end

end
