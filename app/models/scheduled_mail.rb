class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id,
                  :recipient_email, :delivered_at, :contact_id,
                  :username, :event_key, :data,
                  :from_display_name, :from_email_address

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  scope :pending, where('delivered_at IS NULL')
  scope :delivered, where('delivered_at IS NOT NULL')

  def formatted_from_address
    address = Mail::Address.new( from_email_address.blank?? account.padma.email : from_email_address )
    address.display_name = ( from_display_name.blank?? account.padma.full_name : from_display_name )
    address.format
  end

  # @return [Boolean]
  def delivered?
    !!delivered_at
  end

  def deliver_now!
    return unless delivered_at.nil?

    bcc = padma_user.try(:email) if self.username

    PadmaMailer.template(
      template,
      data_hash,
      recipient_email,
      bcc,
      from_display_name,
      from_email_address
    ).deliver
    update_attribute :delivered_at, Time.now

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
      contact_drop = ContactDrop.new(contact, padma_user);
      data_hash.merge!({
        'persona' => contact_drop,
        'contact' => contact_drop
      })
    end
    user = (json_data['username'])? PadmaUser.find(json_data['username']) : padma_user
    if user
      data_hash.merge!({'instructor' => UserDrop.new(padma_user)})
    end

    unless event_key.blank?
      case event_key.to_sym
        #when :subscription_change
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
