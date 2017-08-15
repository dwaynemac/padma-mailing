class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.string :key
      t.string :value
      t.integer :trigger_id

      t.timestamps
    end
  end
end
