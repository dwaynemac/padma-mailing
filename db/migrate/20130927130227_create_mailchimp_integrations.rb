class CreateMailchimpIntegrations < ActiveRecord::Migration
  def change
    create_table :mailchimp_integrations do |t|
      t.integer :local_account_id
      t.string  :api_key
      
      t.string  :students_list_id
      t.string  :p_former_students_list_id
      t.string  :p_prospects_list_id
      t.string  :p_nonstudents_list_id
      t.string  :all_nonstudents_list_id
      t.string  :all_list_id

      t.timestamps
    end
  end
end
