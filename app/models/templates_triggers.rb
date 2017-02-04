class TemplatesTriggers < ActiveRecord::Base

  attr_accessible :template_id, :template,
                  :trigger_id, :trigger,
                  :offset_unit, :offset_number, :offset_reference,
                  :from_display_name, :from_email_address,
                  :bccs

  belongs_to :trigger

  belongs_to :template
  validates_presence_of :template

  before_create :set_defaults

  VALID_UNITS = %W(days weeks months years)
  validates_presence_of :offset_unit, if: ->{!self.offset_number.blank?}

  VALID_REFERENCES = {
      communication: %W(communicated_at),
      subscription_change: %W(changed_at),
      trial_lesson: %W(trial_at),
      birthday: %W(birthday_at),
      membership: %W(ends_on)
  }
  
  def formatted_from_address
    address = Mail::Address.new( self.from_email_address.blank?? template.account.padma.email : from_email_address )
    address.display_name = ( self.from_display_name.blank?? template.account.padma.full_name : from_display_name )
    address.format
  end

  # @return [Fixnum] offset in seconds
  def offset
    return nil unless valid_offset_unit?
    self.offset_number.send(self.offset_unit)
  end

  # @return [Boolean]
  def valid_offset_unit?
    %W(hours days weeks months).include? self.offset_unit.pluralize
  end

  # @return [NilClass] if time not available
  # @return [Time]
  def delivery_time(data)
    data.stringify_keys!
    unless data[self.offset_reference].blank?
      ref_time = nil

      begin
        ref_time = data[self.offset_reference].to_time
      rescue ArgumentError
        # if data[tt.offset_reference] is not valid time to_time will raise exception
      end

      if ref_time
        return  ref_time+self.offset
      end
    end
  end
  
  # if a META DISPLAY NAME was used here we resolve it.
  # eg: if display name is :teacher, we get contact's teacher name. 
  def get_from_display_name(data={})
    ScheduledMail.new(
                    local_account_id: trigger.try(:local_account_id),
                    data: ActiveSupport::JSON.encode(data),
                    from_display_name: from_display_name
                    ).get_from_display_name
  end
  
  # if a META DISPLAY NAME was used here we resolve it.
  # eg: if display name is :teacher, we get contact's teacher email. 
  def get_from_email_address(data={})
    ScheduledMail.new(
                    local_account_id: trigger.try(:local_account_id),
                    data: ActiveSupport::JSON.encode(data),
                    from_email_address: from_email_address 
                    ).get_from_email_address
  end

  private

  def set_defaults

    # default offset. now
    self.offset_number = 0 if self.offset_number.nil?
    self.offset_unit   = 'hours' if self.offset_unit.nil?
    self.offset_reference = 'now' if self.offset_reference.nil?

  end

end
