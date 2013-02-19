class TemplatesTriggers < ActiveRecord::Base

  attr_accessible :template_id, :offset_unit, :offset_number, :offset_reference

  belongs_to :trigger

  belongs_to :template
  validates_presence_of :template

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
