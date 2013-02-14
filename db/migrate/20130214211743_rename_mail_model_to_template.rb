class RenameMailModelToTemplate < ActiveRecord::Migration
  def change
    rename_table :mail_models, :templates
  end
end
