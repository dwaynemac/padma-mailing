class DropMailchimp < ActiveRecord::Migration
  def up
    drop_table :mailchimps
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
