class Trigger < ActiveRecord::Base
  attr_accessible :event_name, :local_account_id

  validates_presence_of :local_account_id
  belongs_to :account, :class_name => "Account", :foreign_key => :local_account_id

  has_many :templates_triggerses, dependent: :destroy
  has_many :templates, through: :templates_triggerses

  has_many :filters, dependent: :destroy
end
