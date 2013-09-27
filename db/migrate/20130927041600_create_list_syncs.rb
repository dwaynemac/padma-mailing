class CreateListSyncs < ActiveRecord::Migration
  def change
    create_table :list_syncs do |t|
      t.integer :mailchimp_list_id
      t.string  :local_list_name
      t.string  :local_account_id

      t.timestamps
    end
  end
end
