class List < ActiveRecord::Base
  attr_accessible :api_id, :mailchimp_id, :name
  belongs_to :mailchimp
end
