class ScheduledMail < ActiveRecord::Base
  attr_accessible :local_account_id, :send_at, :template_id, :recipient_email

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id
  belongs_to :template

  validates_presence_of :recipient_email
end
