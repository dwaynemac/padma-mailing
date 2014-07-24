class AddLocalAccountIdToMailchimps < ActiveRecord::Migration
  def change
    add_column :mailchimps, :local_account_id, :integer if table_exists?(:mailchimps)
  end
end
