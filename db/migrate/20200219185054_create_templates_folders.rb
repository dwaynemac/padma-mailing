class CreateTemplatesFolders < ActiveRecord::Migration
  def change
    create_table :templates_folders do |t|
      t.integer    :local_account_id
      t.references :parent_templates_folder
      t.string     :name
      t.timestamps
    end
    add_column :templates, :parent_templates_folder_id, :integer
  end
end
