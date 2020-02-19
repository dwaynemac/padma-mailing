class TemplatesFolder < ActiveRecord::Base
  attr_accessible :parent_templates_folder_id, :name

  belongs_to :account, foreign_key: :local_account_id
  belongs_to :parent, foreign_key: :parent_templates_folder_id, class_name: "TemplatesFolder"

  has_many :templates

  def self.for_folder(folder_id=nil)
    if folder_id.nil?
      self.scoped
    else
      self.where(parent_templates_folder_id: folder_id)
    end
  end

end
