class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :api_id
      t.integer :mailchimp_id
      t.string :name
      t.belongs_to :mailchimp

      t.timestamps
    end
  end
end
