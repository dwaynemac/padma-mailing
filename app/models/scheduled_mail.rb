class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id, :recipient_email, :delivered_at

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email

  def deliver_now!
    return unless delivered_at.nil?
    PadmaMailer.template(template, recipient_email, nil, account.padma.email).deliver
    update_attribute :delivered_at, Time.now
  end
end
