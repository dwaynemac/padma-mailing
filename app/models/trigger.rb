# Trigger will schedule templates
# when event_name is received matching given filters
# Delivery will be scheduled according to speficied offset.
# If no offset is set delivery will be in the moment.
class Trigger < ActiveRecord::Base
  attr_accessible :event_name, :local_account_id, :filters_attributes, :templates_triggerses_attributes

  VALID_EVENT_NAMES = [
      'communication',
      'subscription_change',
      'trial_lesson',
      'birthday'
  ]

  validates_presence_of :local_account_id
  belongs_to :account, :class_name => "Account", :foreign_key => :local_account_id

  has_many :templates_triggerses, dependent: :destroy, class_name: 'TemplatesTriggers'
  accepts_nested_attributes_for :templates_triggerses

  has_many :templates, through: :templates_triggerses

  has_many :filters, dependent: :destroy
  accepts_nested_attributes_for :filters

  # @param key_name [String]
  # @param data [Hash]
  def self.catch_message(key_name, data)
    return if data['avoid_mailing_triggers']
    return unless where(event_name: key_name).exists? # avoid call to padma-contacts if there is no trigger.
    return unless (recipient_email = get_recipient_email(data))

    message_account = Account.find_by_name(data['account_name'])
    trigger_scope = message_account.nil? ? Trigger : message_account.triggers
    trigger_scope.where(event_name: key_name).each do |trigger|
      if trigger.filters_match?(data)
        trigger.templates_triggerses.includes(:template).each do |tt|
          if (send_at = tt.delivery_time(data))
            ScheduledMail.create(
                template_id: tt.template_id,
                local_account_id: tt.template.local_account_id,
                recipient_email: recipient_email,
                contact_id: data['contact_id'],
                username: data['username'],
                send_at: send_at
            )
          end
        end
      end
    end
  end

  # @param data [Hash]
  # @return [Boolean]
  def filters_match?(data)
    if passes_internal_filters(data)
      filter_count = self.filters.count
      match_count = 0
      self.filters.each{|f| match_count += 1 if data[f.key] == f.value }
      filter_count == match_count
    else
      false
    end
  end

  private

  # @return [String] recipient email
  # @return [NilClass] if no email found.
  def self.get_recipient_email(data)
    return nil unless data['contact_id'] || data['recipient_email']

    recipient_email = data['recipient_email']
    if recipient_email.blank?
      if (contact = PadmaContact.find(data['contact_id'], select: [:email]))
        recipient_email = contact.email
      end
    end

    recipient_email
  end

  # @return true if contact is not listed as a student in another School, while being former_student or prospect
  # false otherwise.
  def is_not_another_schools_student(data)
    # If contact is former_student, it should be able to send the email
    return !(data["local_status_for_#{account.name}"] != "student" && data['status'] == "student")
  end

  # check if it has to make additional checks
  def passes_internal_filters(data)
    if(event_name == 'birthday')
      return is_not_another_schools_student(data)
    else
      true
    end
  end
end
