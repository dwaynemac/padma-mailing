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
 end
