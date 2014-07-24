class RemoveListFromMailchimps < ActiveRecord::Migration
  def change
    remove_column :mailchimps, :list if table_exists?(:mailchimps)
  end
end
