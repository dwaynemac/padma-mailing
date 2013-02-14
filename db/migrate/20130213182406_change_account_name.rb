class ChangeAccountName < ActiveRecord::Migration
  def change
    rename_column :mail_models, :account_id, :account
  end
end
