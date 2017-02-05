class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id,
                  :delivered_at, :contact_id,
                  :username, :event_key, :data,
                  :from_display_name, :from_email_address,
                  :bccs,
                  :recipient_email

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  scope :pending, where('delivered_at IS NULL')
  scope :delivered, where('delivered_at IS NOT NULL')

  def formatted_from_address
    address = Mail::Address.new( get_from_email_address )
    address.display_name = get_from_display_name 
    address.format
  end
  
  def get_bccs
    if self.bccs.blank?
      padma_user.try(:email) if self.username
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
    account.try(:padma).try(:full_name)
  end

  # @return [Boolean]
  def delivered?
    !!delivered_at
  end

  def deliver_now!
    return unless delivered_at.nil?
    
    # freeze FROM address for history
    new_attributes = {}
    
    new_attributes = new_attributes.merge( { from_display_name: get_from_display_name } )
    new_attributes = new_attributes.merge( { from_email_address: get_from_email_address} )
    
    # freeze BCCs address for history
    new_attributes = new_attributes.merge( { bccs: get_bccs } )

    PadmaMailer.template(
      template,
      data_hash,
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

  def as_json(options = nil)
    options ||= {}

    json = super options

    json[:template_name] = self.template.name
    json
  end

  def padma_user
    unless @padma_user
       @padma_user = PadmaUser.find(self.username) if self.username
    end
    return @padma_user
  end

  def data_hash
    data_hash = {}
    json_data = data.blank?? {} : ActiveSupport::JSON.decode(data)

    contact_id = json_data['contact_id'] || self.contact_id
    if contact_id
      contact = PadmaContact.find(contact_id,
                                select: [:email,
                                         :first_name,
                                         :last_name,
                                         :gender,
                                         :global_teacher_username
                                        ]
                               )
      teacher = PadmaUser.find_with_rails_cache(contact.global_teacher_username) if contact.try(:global_teacher_username)
      contact_drop = ContactDrop.new(contact, (teacher || padma_user));
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
          trial_lesson_drop = TrialLessonDrop.new(trial_at, padma_user)
          data_hash.merge!({
            'trial_lesson' => trial_lesson_drop,
            'clase_prueba' => trial_lesson_drop
          })
        #when :birthday
        #when :membership
      end
    end

    data_hash
  end
end
