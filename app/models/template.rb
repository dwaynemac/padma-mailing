class Template < ActiveRecord::Base

  attr_accessible :content, :description, :name, :subject

  validates_presence_of :subject
  validates_presence_of :name

  validates_presence_of :account
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

  has_many :templates_triggerses, dependent: :destroy
  has_many :triggers, through: :templates_triggerses

  def creation_activity(contact_id, user)
    ActivityStream::Activity.new(target_id: contact_id, target_type: 'Contact',
                                 object_id: self.id, object_type: 'Template',
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: "Mail sent: #{self.name}",
                                 public: false,
                                 username: user.username,
                                 account_name: user.current_account.name,
                                 created_at: Time.zone.now.to_s,
                                 updated_at: Time.zone.now.to_s )
  end

  def schedule_deliver(to, bcc, from, user, contact_id)
    schedule = ScheduledMail.create(
                                 template_id: this,
                                 local_account_id: user.current_account.id,
                                 recipient_email: to)
    schedule.deliver(to, bcc, from, user, contact_id)
  end
end
