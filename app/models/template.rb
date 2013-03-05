class Template < ActiveRecord::Base
  attr_accessible :content, :description, :name, :subject, :attachments_attributes

  validates_presence_of :subject
  validates_presence_of :name

  validates_presence_of :account
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

  has_many :templates_triggerses, dependent: :destroy
  has_many :attachments
  has_many :triggers, through: :templates_triggerses

  accepts_nested_attributes_for :attachments, :allow_destroy => true

end
