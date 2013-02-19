class Filter < ActiveRecord::Base
  attr_accessible :key, :trigger_id, :value

  belongs_to :trigger
  validates_presence_of :trigger_id

  validates_presence_of :key
  validates_presence_of :value
end
