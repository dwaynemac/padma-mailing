class MailModel < ActiveRecord::Base
  attr_accessible :content, :description, :name, :subject
  validates_presence_of :subject
  validates_presence_of :name
  validates_presence_of :account_id

end
