class Mailchimp::List < ActiveRecord::Base
  # attr_accessible :api_id
  # attr_accessible :mailchimp_configuration_id
  # attr_accessible :name
  # attr_accessible :mailchimp_segments_attributes
  # attr_accessible :contact_attributes
  # attr_accessible :receive_notifications
  # attr_accessible :webhook_configuration

  DEFAULT_NOTIFICATIONS =
    {
      "id" => '',
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
    account_config = mailchimp_configuration.account.padma

    I18n.locale = account_config.locale unless account_config.nil?
    Time.zone = account_config.timezone unless account_config.nil?

    case type
    when "subscribe"
      contact_id = get_contact_id_by_email(params["data"]["email"])
      message = I18n.t("mailchimp.webhook.subscribed_to", list_name: name)
      subscription_change(message,contact_id)
    when "unsubscribe"
      contact_id = get_contact_id_by_email(params["data"]["email"])
      if params["data"]["action"] == "unsub"
        message = I18n.t("mailchimp.webhook.unsubscribed_from", list_name: name)
      else
        message = I18n.t("mailchimp.webhook.deleted_from", list_name: name)
      end

      if params["data"]["reason"] == "abuse"
        message << I18n.t("mailchimp.webhook.abuse_reason")
      end

      subscription_change(message, contact_id)
    when "cleaned"
      contact_id = get_contact_id_by_email(params["data"]["email"])

      message = I18n.t("mailchimp.webhook.cleaned_from", list_name: name)
      if params["data"]["reason"] == "hard"
        message << I18n.t("mailchimp.webhook.bounce_reason")
      else
        message << I18n.t("mailchimp.webhook.abuse_reason")
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

    PadmaCrmApi.new.create_comment(
      comment_type: "System",
      contact_id: contact_id,
      observations: message,
      public: false,
      username: "mailing_system",
      account_name: mailchimp_configuration.account.name,
      commented_at: Time.zone.now
    )
  end

  def inform_campaign(campaign_name)
    a = ActivityStream::Activity.new(
      target_id: 'Contact',
      target_type: 'contact-still-not-created',
      object_id: id,
      object_type: 'Mailchimp::List',
      generator: ActivityStream::LOCAL_APP_NAME,
      content: I18n.t("mailchimp.webhook.campaign_sent", list_name: name, campaign_name: campaign_name),
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
          events: decode(webhook_configuration)["events"],
          sources: decode(webhook_configuration)["sources"]
        }
      ).body
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      resp = { "id" => nil, errors: get_errors(e.body) }
    end

    if resp["id"].nil?
      self.errors.add(:base, resp[:errors])
    else
      new_config = decode(webhook_configuration)
      new_config[:id] = resp["id"]
      update_attribute(:webhook_configuration, encode(new_config))
      update_attribute(:receive_notifications, true)
    end
  end
  #handle_asynchronously :add_webhook

  def update_notifications(params)
    notifications = decode(webhook_configuration)
    previous_notifications = notifications
    
    notifications["events"] = params["events"]
    notifications["sources"] = params["sources"]
    update_attribute(:webhook_configuration, encode(notifications))
    resp = update_webhook
    
    if resp["id"].nil?
      update_attribute(:webhook_configuration, encode(previous_notifications))
    end
    
    resp
  end

  def update_webhook
    get_api
    webhook = decode(webhook_configuration)

    begin
      @api.lists(api_id).webhooks(webhook["id"]).update(
        body: {
          events: webhook["events"],
          sources: webhook["sources"]
        }
      ).body
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      return { "id" => nil, errors: get_errors(e.body) }
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
      webhook = decode(webhook_configuration)
      @api.lists(api_id).webhooks(webhook["id"]).delete
      webhook["id"] = ""
      update_attribute(:webhook_configuration, encode(webhook))
      update_attribute(:receive_notifications, false)
    rescue Gibbon::MailChimpError => e
      Rails.logger.info "Mailchimp webhook failed with error: #{e}"
      return {errors: get_errors(e.body)}
    end
  end

  def get_webhook_configuration
    update_attribute(:webhook_configuration, encode(DEFAULT_NOTIFICATIONS)) if webhook_configuration.blank?
    decode(webhook_configuration)
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

  def reset_notifications
    notifications = decode(webhook_configuration)
    notifications["events"] = DEFAULT_NOTIFICATIONS["events"]
    notifications["sources"] = DEFAULT_NOTIFICATIONS["sources"]
    update_attribute(:webhook_configuration, encode(notifications))
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
    CrmLegacyContact.search(
      where: {
        email: email
      },
      account_name: mailchimp_configuration.account.name,
      select: [:id]
    ).first.try :id
  end

  def get_errors(e)
    errors = ""
    if e["errors"].nil?
      errors = "#{e["title"]}: #{e["detail"]}"
    else
      e['errors'].each_with_index do |current_error, i|
        errors << "#{current_error['field']}: #{current_error['message']}"
        errors << " - " unless ( i == e["errors"].count - 1 )
      end
    end

    errors
  end

  def subscriber_hash(email)
    Digest::MD5.hexdigest(email.downcase) unless email.nil?
  end

end
