class CreateMailchimpSegments < ActiveRecord::Migration
  def change
    create_table :mailchimp_segments do |t|
      t.text :query
      t.string :api_id
      t.integer :mailchimp_list_id
      t.string :name

      t.timestamps
    end
  end
end
