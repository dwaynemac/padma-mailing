class AddLocalAccountIdToMailchimps < ActiveRecord::Migration
  def change
    add_column :mailchimps, :local_account_id, :integer
  end
end
