class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id, :recipient_email, :delivered_at, :contact_id, :username

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  def deliver_now!
    return unless delivered_at.nil?

    bcc = PadmaUser.find(self.username).try(:email) if self.username

    PadmaMailer.template(template, recipient_email, bcc, account.padma.email).deliver
    update_attribute :delivered_at, Time.now

    # Send notification to activities
    if !self.contact_id.nil?
      a = creation_activity(self.contact_id, self.username)
      a.create()
    end
  end

  def creation_activity(contact_id, username)
    ActivityStream::Activity.new(target_id: contact_id, target_type: 'Contact',
                                 object_id: self.id, object_type: 'Template',
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: "Mail sent: #{self.name}",
                                 public: false,
                                 username: username || "Mailing system",
                                 account_name: account.name,
                                 created_at: Time.zone.now.to_s,
                                 updated_at: Time.zone.now.to_s )
  end

end
