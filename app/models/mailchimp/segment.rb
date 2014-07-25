class Mailchimp::Segment < ActiveRecord::Base
  attr_accessible :api_id
  attr_accessible :mailchimp_list_id
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
  
  
  # At least one selected but not all of them
  def status_restricted?
    (prospect || exstudent || student) &&
      !(prospect && exstudent && student)
  end
 end
