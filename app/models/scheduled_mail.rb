class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id, :recipient_email, :delivered_at

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  def deliver_now!
    return unless delivered_at.nil?

    PadmaMailer.template(template, recipient_email, nil, account.padma.email).deliver
    update_attribute :delivered_at, Time.now

    # Send notification to activities
    # TODO Hago que todos los scheduledMail tengan un contact.id asociado?
    if !contact_id.nil?
      a = creation_activity(contact_id)
      a.create()
    end
  end

  def creation_activity(contact_id)
    ActivityStream::Activity.new(target_id: contact_id, target_type: 'Contact',
                                 object_id: self.id, object_type: 'Template',
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: "Mail sent: #{self.name}",
                                 public: false,
                                 username: "Mailing system",
                                 account_name: "Mailing system",
                                 created_at: Time.zone.now.to_s,
                                 updated_at: Time.zone.now.to_s )
  end

  def deliver(to, bcc, from, contact_id)

    # Deliver mail
    self.deliver_now!

    # Send notification to activities
    if !contact_id.nil?
      a = creation_activity(contact_id)
      a.create()
    end
  end
end
