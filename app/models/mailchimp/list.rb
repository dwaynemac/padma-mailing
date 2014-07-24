class Mailchimp::List < ActiveRecord::Base
  
  # This is a bug in Rails 3.2 that is fixed in Rails 4.0.0.
  self.table_name = 'mailchimp_lists'
  
  attr_accessible :api_id
  attr_accessible :mailchimp_configuration_id
  attr_accessible :name
  
  belongs_to :mailchimp_configuration, foreign_key: :mailchimp_configuration_id, class_name: "Mailchimp::Configuration" 
  has_many :mailchimp_segments, foreign_key: :mailchimp_list_id, class_name: "Mailchimp::Segment"
end
