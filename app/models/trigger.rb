# Trigger will schedule templates
# when event_name is received matching given filters
# Delivery will be scheduled according to speficied offset.
# If no offset is set delivery will be in the moment.
class Trigger < ActiveRecord::Base
  attr_accessible :event_name, :local_account_id, :filters_attributes, :templates_triggerses_attributes

  VALID_EVENT_NAMES = [
      'communication',
      'subscription_change'
  ]

  validates_presence_of :local_account_id
  belongs_to :account, :class_name => "Account", :foreign_key => :local_account_id

  has_many :templates_triggerses, dependent: :destroy, class_name: 'TemplatesTriggers'
  accepts_nested_attributes_for :templates_triggerses

  has_many :templates, through: :templates_triggerses

  has_many :filters, dependent: :destroy
  accepts_nested_attributes_for :filters

  # @param key_name [String]
  # @param data [Hash]
  def self.catch_message(key_name, data)

  end

end
