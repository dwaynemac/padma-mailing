class Segment < ActiveRecord::Base
  attr_accessible :api_id, :query
  belongs_to :list
  
  serialize :query, Hash
  
end
