class Segment < ActiveRecord::Base
  attr_accessible :api_id, :query
  has_one :mailchimp
  
  serialize :query, Hash
end
