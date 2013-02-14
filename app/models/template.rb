class Template < ActiveRecord::Base
  attr_accessible :content, :description, :name, :subject

  validates_presence_of :subject
  validates_presence_of :name
  validates_presence_of :account

  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

end
