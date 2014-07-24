class DropListTable < ActiveRecord::Migration
  def up
    drop_table :lists if table_exists?(:lists)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
