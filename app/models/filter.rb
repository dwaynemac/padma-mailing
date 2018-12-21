class Filter < ActiveRecord::Base
  attr_accessible :key, :trigger_id, :value

  belongs_to :trigger

  validates_presence_of :key
  validates_presence_of :value

  # only when trigger's event is Birthday (because it's a global event.)
  before_save :convert_local_attributes, if: ->{ trigger.event_name == 'birthday' }

  SUGGESTED_VALUES = {
      communication: {
          media: %W(interview phone_call email website_contact),
          #global_status: %W(student former_student prospect),
          local_status: %W(student former_student prospect),
          estimated_coefficient: %W(unknown fp pmenos perfil pmas)
      },
      subscription_change: {
          type: %W(Enrollment DropOut)
      },
      birthday: {
          #global_status: %W(student former_student prospect),
          local_status: %W(student former_student prospect),
          local_coefficient: %W(unknown fp pmenos perfil pmas),
          gender: %W(male female)
      },
      next_action: {
        type: %W(interview)
      }
  }

  private

  # Converts local_XX to local_XX_for_AccountName
  def convert_local_attributes
    if trigger.account
      if key =~ /local_(\w+)/
        self.key = "local_#{$1}_for_#{trigger.account.name}"
      end
    end
  end

=begin
  def self.i18n_suggested_values
    ret = {}
    SUGGESTED_VALUES.each_pair do |key,value|
      ret[key] = {}
      value.keys.each{|k| ret[key][k] = []}
      value.each_pair do |k,v|
        ret[key][k] << [v,I18n.t("filter.suggested_values.#{v}")]
      end
    end
    ret
  end
=end

end
