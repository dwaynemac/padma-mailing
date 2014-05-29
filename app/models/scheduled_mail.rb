class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id, :recipient_email, :delivered_at, :contact_id, :username, :event_key, :data

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  scope :pending, where('delivered_at IS NULL')

  # @return [Boolean]
  def delivered?
    !!delivered_at
  end

  def deliver_now!
    return unless delivered_at.nil?

    bcc = padma_user.try(:email) if self.username

    PadmaMailer.template(template, data_hash, recipient_email, bcc, account.padma.email).deliver
    update_attribute :delivered_at, Time.now

    # Send notification to activities
    if !self.contact_id.nil?
      a = creation_activity
      a.create(username: self.username, account_name: account.name)
    end
  end

  def creation_activity
    ActivityStream::Activity.new(target_id: self.contact_id, target_type: 'Contact',
                                 object_id: template.id, object_type: 'Template',
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
       @padma_user = PadmaUser.find(self.username)
    end
    return @padma_user
  end

  def data_hash
    data_hash = {}
    data_from_messaging = ActiveSupport::JSON.decode(data)

    contact = PadmaContact.find(data_from_messaging['contact_id'], select: [:email, :first_name, :last_name, :gender, :global_teacher_username])
    contact_drop = ContactDrop.new(contact, padma_user);
    
    data_hash.merge({
      'persona' => contact_drop,
      'contact' => contact_drop
    })

    case event_key.to_sym
      #when :subscription_change
      #when :communication
      when :trial_lesson
        trial_at = data_from_messaging[:trial_at]
        trial_lesson_drop = TrialLessonDrop.new(trial_at, padma_user)
        data_hash.merge({
          'trial_lesson' => trial_lesson_drop,
          'clase_prueba' => trial_lesson_drop
        })
      #when :birthday
      #when :membership
    end
  end
end
