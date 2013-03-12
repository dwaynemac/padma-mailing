class Template < ActiveRecord::Base
  attr_accessible :content, :description, :name, :subject, :attachments_attributes, :attachments

  validates_presence_of :subject
  validates_presence_of :name

  validates_presence_of :account
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

  has_many :templates_triggerses, dependent: :destroy, class_name: 'TemplatesTriggers'
  has_many :triggers, through: :templates_triggerses, class_name: 'TemplatesTriggers'
  has_many :attachments

  accepts_nested_attributes_for :attachments, :reject_if => lambda { |a| a[:file].nil? }, :allow_destroy => true

  def deliver(data)
    user = data[:user]
    schedule = ScheduledMail.create(
                                 send_at: Time.zone.now,
                                 template_id: self.id,
                                 local_account_id: user.current_account.id,
                                 recipient_email: data[:to],
                                 contact_id: data[:contact_id],
                                 username: user.username)
    schedule.deliver_now!
  end

end
