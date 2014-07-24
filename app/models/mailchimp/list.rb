class Mailchimp::List < ActiveRecord::Base
  
  # This is a bug in Rails 3.2 that is fixed in Rails 4.0.0.
  self.table_name = 'mailchimp_lists'
  
  attr_accessible :api_id
  attr_accessible :mailchimp_configuration_id
  attr_accessible :name
end
