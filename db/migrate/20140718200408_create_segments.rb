class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.text :query
      t.string :api_id
      t.belongs_to :mailchimp

      t.timestamps
    end
  end
end
