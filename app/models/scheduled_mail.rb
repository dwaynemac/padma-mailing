class ScheduledMail < ActiveRecord::Base
  # attr_accessible :local_account_id, :send_at, :template_id,
  #                :delivered_at, :contact_id,
  #                :username, :event_key, :data, :conditions,
  #                :from_display_name, :from_email_address,
  #                :bccs,
  #                :recipient_email, :cancelled

  paginates_per 20
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  scope :pending, -> { where('delivered_at IS NULL') }
  scope :delivered, -> { where('delivered_at IS NOT NULL') }

  def formatted_from_address
    address = Mail::Address.new( get_from_email_address )
    address.display_name = get_from_display_name 
    address.format
  end
  
  def get_bccs
    if self.bccs.blank?
      # padma_user.try(:email) if self.username
    else
      parse_liquid(bccs,data_hash)
    end
  end
  
  def get_from_display_name
    self.from_display_name.blank?? default_from_display_name : parse_liquid(from_display_name,data_hash)
  end
  
  def get_from_email_address
    self.from_email_address.blank?? default_from_email_address : parse_liquid(from_email_address,data_hash)
  end
  
  def parse_liquid(text,data)
    parsed = Liquid::Template.parse(text).render(data)
    if parsed =~ /Liquid error/
      ''
    else
      parsed
    end
  end
  
  def default_from_email_address
    account.try(:padma).try(:email)
  end
  
  def default_from_display_name
    account.try(:padma).try(:branded_name)
  end

  # @return [Boolean]
  def delivered?
    !!delivered_at
  end

  def deliver_now!
    contact_data = data_hash
    unless conditions_met?(contact_data)
      Rails.logger.info "Mail with data #{contact_data} cancelled, conditions not met."
      
      update_attributes({
        cancelled: true, 
        delivered_at: Time.now })
    end
    
    return unless delivered_at.nil?
    
    # freeze FROM address for history
    new_attributes = {}
    
    new_attributes = new_attributes.merge( { from_display_name: get_from_display_name } )
    new_attributes = new_attributes.merge( { from_email_address: get_from_email_address} )
    
    # freeze BCCs address for history
    new_attributes = new_attributes.merge( { bccs: get_bccs } )

    PadmaMailer.template(
      template,
      contact_data,
      recipient_email,
      get_bccs,
      get_from_display_name,
      get_from_email_address
    ).deliver
    new_attributes = new_attributes.merge( { delivered_at: Time.now } )
    
    update_attributes(new_attributes)

    # Send notification to activities
    if !self.contact_id.nil?
      a = creation_activity
      a.create(username: self.username, account_name: account.name)
    end
  end

  def creation_activity
    account_config = account.padma

    I18n.locale = account_config.locale unless account_config.nil?
    Time.zone = account_config.timezone unless account_config.nil?

    ActivityStream::Activity.new(target_id: self.contact_id,
                                 target_type: 'Contact',
                                 object_id: template.id,
                                 object_type: 'Template',
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: "Mail sent: #{template.name}",
                                 public: false,
                                 username: self.username || "Mailing system",
                                 account_name: account.name,
                                 created_at: Time.zone.now.to_s,
                                 updated_at: Time.zone.now.to_s )
  end

  def conditions_met?(contact_data)
    return true if conditions.blank?
    decoded_conditions = ActiveSupport::JSON.decode(conditions)
    conditions_count = decoded_conditions.keys.count
    match_count = 0
    decoded_conditions.keys.each{|key| match_count +=1 if contact_data["conditions"][key] == decoded_conditions[key]}
    conditions_count == match_count
  end

  def as_json(options = nil)
    options ||= {}

    json = super options

    json[:template_name] = self.template.name
    json
  end

  def padma_user
    unless @padma_user
       @padma_user = PadmaUser.find_with_rails_cache(self.username) if self.username
    end
    return @padma_user
  end

  def data_hash
    data_hash = {}
    json_data = data.blank?? {} : ActiveSupport::JSON.decode(data)
    conditions_hash = conditions.blank? ? {} : ActiveSupport::JSON.decode(conditions)

    contact_id = json_data['contact_id'] || self.contact_id
    if contact_id
      select_options = [:email, :first_name, :last_name, :gender, :global_teacher_username]
      select_options += conditions_hash.keys.map(&:to_sym) unless conditions_hash.blank?
      contact = PadmaContact.find(contact_id, select: select_options, account_name: account.name)
      teacher = PadmaUser.find_with_rails_cache(contact.local_teacher) if contact.try(:local_teacher)
      contact_drop = ContactDrop.new(contact, (teacher || padma_user));
      unless conditions_hash.blank?
        conditions_to_be_added = {}
        conditions_hash.keys.each do |key|
          conditions_to_be_added[key] = contact.send(key) 
        end
        data_hash.merge!({"conditions" => conditions_to_be_added})
      end

      data_hash.merge!({
        'persona' => contact_drop,
        'contact' => contact_drop
      })
    end
    user = (json_data['username'])? PadmaUser.find_with_rails_cache(json_data['username']) : padma_user
    if user
      data_hash.merge!({'instructor' => UserDrop.new(padma_user)})
    end

    unless event_key.blank?
      case event_key.to_sym
        when :subscription_change
          
          subscription_change_drop = SubscriptionChangeDrop.new(
            contact_drop: contact_drop,
            instructor_drop: user
          )
          data_hash.merge!('subscription_change' => subscription_change_drop)
          data_alias = if json_data['type'] == 'Enrollment'
            'enrollment'
          elsif json_data['type'] == 'DropOut'
            'dropout'
          end
          data_hash.merge!(data_alias => subscription_change_drop)
          
        #when :communication
        when :trial_lesson
          trial_at = json_data['trial_at']
          time_slot = AttendanceClient::TimeSlot.find json_data['time_slot_id']
          trial_lesson_drop = TrialLessonDrop.new(trial_at, padma_user, time_slot)
          data_hash.merge!({
            'trial_lesson' => trial_lesson_drop,
            'clase_prueba' => trial_lesson_drop
          })
        #when :birthday
        #when :membership
        when :next_action
          action_on = json_data['action_on']
          will_interview = (json_data['will_interview_username'])? PadmaUser.find_with_rails_cache(json_data['will_interview_username']) : padma_user
          next_action_drop = NextActionDrop.new(
            action_on, padma_user, will_interview, account.padma.timezone
          )
          data_hash.merge!({
            'next_action' => next_action_drop
          })
      end
    end

    data_hash
  end
end
