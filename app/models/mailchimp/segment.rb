class Mailchimp::Segment < ActiveRecord::Base
  attr_accessible :api_id
  attr_accessible :mailchimp_list_id
  attr_accessible :contact_segment_id
  attr_accessible :prospect
  attr_accessible :exstudent
  attr_accessible :student
  attr_accessible :only_man
  attr_accessible :coefficient
  attr_accessible :name

  belongs_to :mailchimp_list, foreign_key: :mailchimp_list_id, class_name: "Mailchimp::List"
  
  validate :segment_must_restrict_list
  validates :name, presence: true
  
  def segment_must_restrict_list
    if !status_restricted? && !only_man &&
        (coefficient == 'all' || coefficient.nil?)
      errors.add(:restriction, 'Segment must restrict list members in some way')
    end 
  end
  
  def create_segment_in_mailchimp
    @config = get_configuration
    I18n.locale = @config.account.padma.locale
    @config.api.lists.segment_add({
      id: self.mailchimp_list.api_id,
      opts: {
        type: 'saved',
        name: self.name,
        segment_opts: {
          match: 'all',
          conditions: self.get_conditions
        }
      }
    })
  end
  
  def get_conditions
    conditions = []
    conditions.push status_condition
    conditions.push gender_condition if only_man
    conditions.push coefficient_condition if coefficient != 'all'
    conditions
  end
  
  # The order here is IMPORTANT 
  def status_condition
    value = '|'
    value << 'p' if prospect
    value << 's' if student
    value << 'f' if exstudent
    value << '|'
    {
      field: 'SYSSTATUS',
      op: 'contains',
      value: value
    }
  end
  
  def gender_condition
    {
      field: 'GENDER',
      op: 'is',
      value: I18n.t('mailchimp.segment.man')
    }
  end
  
  def coefficient_condition
    {
      field: 'SYSCOEFF',
      op: 'is',
      value: coefficient
    }
  end
  
  private  
  # At least one selected but not all of them
  def status_restricted?
    (prospect || exstudent || student) &&
      !(prospect && exstudent && student)
  end
  
  def get_configuration
    self.mailchimp_list.mailchimp_configuration
  end
  
end
