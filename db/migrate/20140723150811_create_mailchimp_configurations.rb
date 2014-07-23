class CreateMailchimpConfigurations < ActiveRecord::Migration
  def change
    create_table :mailchimp_configurations do |t|
      t.string :api_key
      t.integer :local_account_id
      t.integer :primary_list_id

      t.timestamps
    end
  end
end
