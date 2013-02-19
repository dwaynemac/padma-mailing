# Trigger will schedule templates
# when event_name is received matching given filters
# Delivery will be scheduled according to speficied offset.
# If no offset is set delivery will be in the moment.
class Trigger < ActiveRecord::Base
  attr_accessible :event_name, :local_account_id, :offset_number, :offset_reference, :offset_unit, :filte

  validates_presence_of :local_account_id
  belongs_to :account, :class_name => "Account", :foreign_key => :local_account_id

  has_many :templates_triggerses, dependent: :destroy
  has_many :templates, through: :templates_triggerses

  has_many :filters, dependent: :destroy
  accepts_nested_attributes_for :filters

  before_create :set_defaults

  validates_presence_of :offset_unit, if: ->{!offset_number.blank?}

  # @return [Fixnum] offset in seconds
  def offset
    return nil unless valid_offset_unit?

    self.offset_number.send(self.offset_unit)
  end

  # @return [Boolean]
  def valid_offset_unit?
    %W(hours days weeks months).include? self.offset_unit.pluralize
  end

  private

  def set_defaults

    # default offset. now
    self.offset_number = 0 if self.offset_number.nil?
    self.offset_unit   = 'hours' if self.offset_unit.nil?
    self.offset_reference = 'now' if self.offset_reference.nil?

  end

end
