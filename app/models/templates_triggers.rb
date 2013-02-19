class TemplatesTriggers < ActiveRecord::Base

  belongs_to :trigger
  validates_presence_of :trigger

  belongs_to :template
  validates_presence_of :template
end
