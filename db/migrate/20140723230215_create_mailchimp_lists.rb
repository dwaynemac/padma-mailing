class CreateMailchimpLists < ActiveRecord::Migration
  def change
    create_table :mailchimp_lists do |t|
      t.string :api_id
      t.integer :mailchimp_configuration_id
      t.string :name

      t.timestamps
    end
  end
end
