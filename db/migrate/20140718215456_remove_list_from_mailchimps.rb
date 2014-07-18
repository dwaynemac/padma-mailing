class RemoveListFromMailchimps < ActiveRecord::Migration
  def up
    remove_column :mailchimps, :list
  end

  def down
    add_column :mailchimps, :list, :string
  end
end
