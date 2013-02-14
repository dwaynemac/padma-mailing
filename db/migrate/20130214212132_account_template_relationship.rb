class AccountTemplateRelationship < ActiveRecord::Migration
  def change
    rename_column :templates, :account, :local_account_id
    change_column :templates, :local_account_id, :integer
  end
end
