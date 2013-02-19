class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.integer :trigger_id
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
