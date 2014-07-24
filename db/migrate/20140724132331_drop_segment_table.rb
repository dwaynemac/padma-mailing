class DropSegmentTable < ActiveRecord::Migration
  def up
    drop_table :segments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
