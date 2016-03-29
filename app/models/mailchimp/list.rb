class Mailchimp::List < ActiveRecord::Base
  attr_accessible :api_id
  attr_accessible :mailchimp_configuration_id
  attr_accessible :name
  attr_accessible :mailchimp_segments_attributes
  
  belongs_to :mailchimp_configuration, foreign_key: :mailchimp_configuration_id, class_name: "Mailchimp::Configuration" 

  has_many :mailchimp_segments,
           foreign_key: :mailchimp_list_id,
           class_name: "Mailchimp::Segment",
           dependent: :destroy
  
  accepts_nested_attributes_for :mailchimp_segments,
    allow_destroy: true,
    reject_if: proc { |attr|
      !Mailchimp::Segment.new(attr).valid?
    }

  def primary?
    self.id == self.mailchimp_configuration.primary_list_id
  end
end
