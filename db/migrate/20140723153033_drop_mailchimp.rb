class DropMailchimp < ActiveRecord::Migration
  def up
    drop_table :mailchimps if table_exists?(:mailchimps)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
