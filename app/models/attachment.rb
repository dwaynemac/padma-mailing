class Attachment < ActiveRecord::Base
  attr_accessible :attachment_content_type, :attachment_file_name, :attachment_file_size, :attachment_updated_at, :template_id, :attachment
  belongs_to :template
  has_attached_file :attachment

  do_not_validate_attachment_file_type :attachment
end
