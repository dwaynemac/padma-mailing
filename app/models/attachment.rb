class Attachment < ActiveRecord::Base
  attr_accessible :attachment_content_type, :attachment_file_name, :attachment_file_size, :attachment_updated_at, :template_id
  belongs_to :template
  has_attached_file :attachment
end
