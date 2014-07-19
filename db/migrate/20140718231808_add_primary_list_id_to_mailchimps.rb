class AddPrimaryListIdToMailchimps < ActiveRecord::Migration
  def change
    add_column :mailchimps, :primary_list_id, :integer
  end
end
