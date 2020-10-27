class TemplatesFolder < ActiveRecord::Base
  # attr_accessible :parent_templates_folder_id, :name

  belongs_to :account, foreign_key: :local_account_id
  belongs_to :parent,
             foreign_key: :parent_templates_folder_id,
             class_name: "TemplatesFolder"

  has_many :folders,
           foreign_key: :parent_templates_folder_id,
           class_name: "TemplatesFolder",
           dependent: :nullify

  has_many :templates, dependent: :nullify, foreign_key: :parent_templates_folder_id

  validates :name, presence: true

  def self.for_folder(folder_id=nil)
    self.where(parent_templates_folder_id: folder_id)
  end

end
