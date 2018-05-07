class Mailchimp::List < ActiveRecord::Base
  attr_accessible :api_id
  attr_accessible :mailchimp_configuration_id
  attr_accessible :name
  attr_accessible :mailchimp_segments_attributes
  attr_accessible :contact_attributes
  attr_accessible :receive_notifications
  attr_accessible :webhook_configuration

  DEFAULT_NOTIFICATIONS =
    {
      "events" => {
        "subscribe"=> true,
        "unsubscribe" => true,
        "cleaned" => true,
        "campaign" => true,
        "profile" => false,
        "upemail" => false
      },
      "sources" => {
        "user" => true,
        "admin" => true,
        "api" => false
      }
    }
  
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

  before_create :set_defaults
  after_create :add_webhook

  def primary?
    self.id == self.mailchimp_configuration.primary_list_id
  end

  def create_activity(params)
    type = params["type"]
    
    case type
    when "subscribe"
      contact_id = get_contact_id_by_email(params["data"]["email"])
      message = "Has been subscribed to list: #{name}"
      subscription_change(message,contact_id)
    when "unsubscribe"
      contact_id = get_contact_id_by_email(params["data"]["email"])
      
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

      subscription_change(message, contact_id)
    when "cleaned"
      contact_id = get_contact_id_by_email(params["data"]["email"])

      message = "Has been cleaned due to"
      if params["data"]["reason"] == "hard"
        message << " too many bounces"
      else
        message << "abuse"
      end
      subscription_change(message, contact_id)
    when "campaign"
      if params["data"]["status"] == "sent"
        inform_campaign(params["data"]["subject"])
      end
    end
  end

  def subscription_change(message, contact_id)
    return nil if contact_id.blank?

    a = ActivityStream::Activity.new(
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
    a.create(username: "Mailing system", account_name: mailchimp_configuration.account.name)
  end

  def inform_campaign(campaign_name)
    a = ActivityStream::Activity.new(
      target_id: 'Contact',
      target_type: 'contact-still-not-created',
      object_id: id,
      object_type: 'Mailchimp::List',
      generator: ActivityStream::LOCAL_APP_NAME,
      content: "List #{name}: campaign #{campaign_name} has been sent",
      public: false,
      username: "Mailing system",
      account_name: mailchimp_configuration.account.name,
      created_at: Time.zone.now.to_s,
      updated_at: Time.zone.now.to_s
    )
    a.create(username: "Mailing system", account_name: mailchimp_configuration.account.name)
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
    begin
      @api.lists(api_id).retrieve.body
    rescue Gibbon::MailChimpError => e
      return {status: "failed", message: e}
    rescue
      return {status: "failed", message: "could not get remote list"}
    end
  end

  def batches
    get_api
    begin
      @api.batches.retrieve.body["batches"]
    rescue Gibbon::MailChimpError => e
      return {status: "failed", message: e}
    rescue
      return {status: "failed", message: "could not get batches"}
    end
  end

  def coefficient_group(group_id)
    get_api
    begin
      @api.lists(api_id).interest_categories(group_id).interests.retrieve.body
    rescue Gibbon::MailChimpError => e
      return {status: "failed", message: e}
    rescue
      return {status: "failed", message: "could not get group"}
    end
  end

  def unsubscribed(count = 25, offset = 0)
    get_api
    begin
      @api.lists(api_id).members.retrieve(
        params: {
          status: "unsubscribed",
          fields: "members.merge_fields,members.email_address",
          count: count,
          offset: offset
        }
      ).body["members"]
    rescue Gibbon::MailChimpError
      return nil #TODO show error
    end
  end

  def cleaned(count = 25, offset = 0)
    get_api
    begin
      @api.lists(api_id).members.retrieve(
        params: {
          status: "cleaned", 
          fields: "members.merge_fields,members.email_address",
          count: count,
          offset: offset
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

  def contacts_not_synchronized(search_count = 100)
    get_api

    sc = get_scope(1, search_count)
    if sc["count"] > search_count
      (sc["count"]/search_count).times do |p|
        sc["contacts"] << get_scope(p+2,search_count)["contacts"]
        sc["contacts"].flatten!(1)
      end
    end
    
    mailchimp_members = @api.lists(api_id).members.retrieve(
      params: {
        fields: "members.email_address,total_items",
        count: search_count
      }
    ).body

    if mailchimp_members["total_items"] > search_count
      (mailchimp_members["total_items"]/search_count).times do |p|
        mailchimp_members["members"] << @api.lists(api_id).members.retrieve(
          params: {
            fields: "members.email_address",
            count: search_count,
            offset: (p+1)*search_count
          }
        ).body["members"]
        mailchimp_members["members"].flatten!(1)
      end
    end
    sc["contacts"].map{|c| c["email"]} - mailchimp_members["members"].map{|m| m["email_address"]}
  end

  def remove_member(email)
    return nil if email.blank?
    get_api
    
    begin
      @api.lists(api_id).members(subscriber_hash(email)).delete
    rescue Gibbon::MailChimpError => e
      return {status: false, message: e.message}
    end

    {status: true}
  end


  # Adds a webhook to receive information about the MailChimp List
  #
  # options tell which events to listen for
  # default values are subscribe, unsubscribe, cleaned and campaign
  #
  # sources tell which source to listen for an action
  # user when the user subscribes/unsubcribes
  # admin when the MailChimp admin makes the changes
  # api when the api makes the changes
  # all are true by default
  #
  # options sent has to have every option, and set to true or false
  # or it will load defaults
  #
  # same for sources
  #
  # options = {
  #   events: {
  #     subscribe: true,
  #     unsubscribe: true,
  #     cleaned: true,
  #     campaign: true,
  #     profile: false,
  #     upemail: false
  #   },
  #   sources: {
  #     user: true,
  #     admin: true,
  #     api: false
  #   }
  # }

  def add_webhook
    get_api
    resp = {}
    begin
      resp = @api.lists(api_id).webhooks.create(
        body: {
          url: Rails.application.routes.url_helpers.webhooks_api_v0_mailchimp_list_url(
            id, 
            only_path: false, 
            host: APP_CONFIG["mailing-url"].gsub("http://","")
          ),
          events: decode(webhook_configuration)[:events],
          sources: decode(webhook_configuration)[:sources]
        }
      ).body
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      resp = { "id" => nil, errors: e.body["errors"] }
    end

    if resp["id"].nil?
      self.errors.add(:base, resp[:errors])
    else
      update_attribute(:receive_notifications, true)
    end
  end
  handle_asynchronously :add_webhook

  def update_webhook(type, key, value)
    get_api
    
    webhook = decode(webhook_configuration)
    webhook[type][key] = (value == "true")
    update_attribute(:webhook_configuration, encode(webhook))

    begin
      webhook = @api.lists(api_id).webhooks.retrieve.body["webhooks"].try :first
      if webhook.nil?
       return {status: false, message: "there is no webhook associated with this list"} 
      else
        @api.lists(api_id).webhooks(webhook["id"]).update(
          body: {
            events: webhook["events"],
            sources: webhook["sources"]
          }
        ).body
      end
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      webhook[type][key] = !webhook[type][key]
      update_attribute(:webhook_configuration, encode(webhook))
      return { id: nil, errors: e.body["errors"] }
    end
  end

  def has_webhook?
    get_api
    resp = nil

    begin
      resp = @api.lists(api_id).webhooks.retrieve.body
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      return false
    end
    return resp["webhooks"].count > 0
  end

  def remove_webhook
    get_api

    begin
      webhook = @api.lists(api_id).webhooks.retrieve.body["webhooks"].try :first
      unless webhook.nil?
        @api.lists(api_id).webhooks(webhook["id"]).delete
      end
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      return nil
    end
  end

  def notifications_valid?(notifications)
    return false if notifications.nil? || notifications.blank?

    return events_valid?(notifications["events"]) && sources_valid?(notifications["sources"])
  end

  def events_valid?(events)
    return false if events.nil?

    return %w(subscribe unsubscribe cleaned campaign profile upemail).all? { |t| !events[t].nil? && ([true, false].include? events[t]) }
  end
  
  def sources_valid?(sources)
    return false if sources.nil?

    return %w(user admin api).all? { |t| !sources[t].nil? && ([true, false].include? sources[t]) }
  end

  def encode(string)
    ActiveSupport::JSON.encode(string)
  end

  def decode(string)
    ActiveSupport::JSON.decode(string)
  end

  private

  def set_defaults
    self.webhook_configuration = encode(DEFAULT_NOTIFICATIONS)
  end
  
  def get_api
    begin
      @api = @api || Gibbon::Request.new(api_key: mailchimp_configuration.api_key)
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp api failed with error: #{e}"
      return nil
    rescue
      return nil
    end
  end

  def get_contact_id_by_email(email)
    PadmaContact.search(
      where: {
        email: email
      },
      account_name: mailchimp_configuration.account.name,
      select: [:id]
    ).first.try :id
  end

  def subscriber_hash(email)
    Digest::MD5.hexdigest(email.downcase) unless email.nil?
  end

end
