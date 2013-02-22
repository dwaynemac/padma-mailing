class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.string :event_name
      t.integer :local_account_id
      t.timestamps
    end
  end
end
