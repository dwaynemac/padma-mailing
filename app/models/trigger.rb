# encoding: UTF-8

# Trigger will schedule templates
# when event_name is received matching given filters
# Delivery will be scheduled according to speficied offset.
# If no offset is set delivery will be in the moment.
class Trigger < ActiveRecord::Base
  # attr_accessible :event_name, :local_account_id, :filters_attributes, :conditions_attributes, :templates_triggerses_attributes

  VALID_EVENT_NAMES = [
      'communication',
      'subscription_change',
      'trial_lesson',
      'birthday',
      'membership',
      'next_action'
  ]

  # This events don't need to come with an account_name. All others MUST.
  GLOBAL_EVENTS = %W(birthday)

  validates_presence_of :local_account_id
  belongs_to :account, :class_name => "Account", :foreign_key => :local_account_id

  has_many :templates_triggerses, dependent: :destroy, class_name: 'TemplatesTriggers'
  accepts_nested_attributes_for :templates_triggerses

  has_many :templates, through: :templates_triggerses

  has_many :filters, dependent: :destroy
  has_many :conditions, dependent: :destroy
  accepts_nested_attributes_for :filters
  accepts_nested_attributes_for :conditions

  # @param key_name [String]
  # @param data [Hash]
  def self.catch_message(key_name, data)
    if data['avoid_mailing_triggers']
      Rails.logger.debug "ignoring message, avoid_mailing_triggers present"
    else
      return unless where(event_name: key_name).exists? # avoid call to padma-contacts if there is no trigger.
      return unless (recipient_email = get_recipient_email(data))

      message_account = Account.find_by_name(data['account_name'])
      return if message_account.nil? && !key_name.in?(GLOBAL_EVENTS)
      return if message_account && !message_account.padma.enabled?

      if key_name.in?(GLOBAL_EVENTS)
        data['username'] = 'system'
      end

      trigger_scope = message_account.present?? message_account.triggers : Trigger

      trigger_scope.where(event_name: key_name).each do |trigger|
        if trigger.account.padma.enabled?
          unless trigger.account.padma.local_mailing
            if trigger.filters_match?(data)
              trigger.templates_triggerses.includes(:template).each do |tt|
                if (send_at = tt.delivery_time(data)) && send_at.to_date >= Time.zone.now.to_date
                  if ScheduledMail.pending.where(template_id: tt.template_id,
                                        local_account_id: tt.template.local_account_id,
                                        recipient_email: recipient_email,
                                        contact_id: data['contact_id'],
                                        username: data['username'],
                                        send_at: send_at.beginning_of_day..send_at.end_of_day
                                                ).count == 0
                    sm = ScheduledMail.new(
                        template_id: tt.template_id,
                        local_account_id: tt.template.local_account_id,
                        recipient_email: recipient_email,
                        bccs: tt.bccs,
                        contact_id: data['contact_id'],
                        username: data['username'],
                        from_display_name: tt.from_display_name,
                        from_email_address: tt.from_email_address,
                        send_at: send_at,
                        event_key: key_name,
                        data: ActiveSupport::JSON.encode(data),
                        conditions: encode_conditions(trigger.conditions)
                    )
                    sm_key = sm.inspect.to_param # before save to avoid id. 
                    if Rails.env.production? && Rails.cache.read("saved_sm:#{sm_key}") 
                      Rails.logger.warn "[notify-sysadmin] Prevented duplicate to #{sm.inspect}"
                    else
                      if sm.save
                        Rails.cache.write("saved_sm:#{sm_key}",true)
                      else
                        Rails.logger.warn "[notify-sysadmin] Couldnt save schedule mail #{sm.inspect}"
                      end
                    end
                  else
                    Rails.logger.debug "ignoring duplicated message"
                  end
                else
                  Rails.logger.debug "ignoring future e-mail"
                end
              end
            else
              Rails.logger.debug "message didnt match filters"
            end
          else
            Rails.logger.debug "triggers account sends mail in CRM"
          end
        else
          Rails.logger.debug "trigger's account is not enabled"
        end
      end
    end
  rescue => e
    Rails.logger.warn "[notify-sysadmin] Catching #{key_name} with load: #{data} failed with exception: #{e.message}"
    raise e
  end

  # @param data [Hash]
  # @return [Boolean]
  def filters_match?(data)
    if passes_internal_filters(data)
      filter_count = self.filters.count
      match_count = 0
      self.filters.each{|f| match_count += 1 if data[f.key].try(:downcase) == f.value.try(:downcase) }
      filter_count == match_count
    else
      false
    end
  end
  

  private

  ##
  # Gets recipient email looking:
  #   1st at data[:recipient_email]
  #   2nd at CrmLegacyContact with id data[:contact_id]
  # @return [String] recipient email
  # @return [NilClass] if no email found.
  def self.get_recipient_email(data)
    return nil unless data['contact_id'] || data['recipient_email']

    recipient_email = data['recipient_email']
    if recipient_email.blank?
      attempts = 3
      contact = nil
      while attempts > 0 && contact.nil? do
        attempts -= 1
        contact = CrmLegacyContact.find(data['contact_id'],
                                    select: [:email],
                                    account_name: data['account_name'])
      end
      if contact
        recipient_email = contact.email
      else
        Rails.logger.info "couldnt get contact #{data['contact_id']} to get email"
      end
    end

    recipient_email
  end

  # @return [Boolean]
  # true if contact is not listed as a student in another School, while being former_student or prospect
  # false otherwise.
  def is_not_another_schools_student?(data)
    # If contact is former_student, it should be able to send the email
    return !(data["local_status_for_#{account.name}"] != "student" && data['status'] == "student")
  end

  ##
  # Checks if in message data if contact specified by data is linked to trigger's account
  # This will simply use data[:linked_accounts_names], contacts-ws is not called
  # @return [Boolean]
  def is_linked_to_account?(data)
    if data['linked_accounts_names']
      data['linked_accounts_names'].include?(account.name)
    end
  end

  # check if it has to make additional checks
  def passes_internal_filters(data)
    if event_name.in?(GLOBAL_EVENTS)
      return is_linked_to_account?(data) && is_not_another_schools_student?(data)
    else
      true
    end
  end

  def self.encode_conditions(conditions)
    if conditions.blank?
      "{}"
    else
      ActiveSupport::JSON.encode(conditions.map{|c| {c.key => c.value}}.reduce(&:merge))
    end
  end
end
