class FixColumnNameMailchimpId < ActiveRecord::Migration
  def change
    rename_column :segments, :mailchimp_id, :list_id
  end
end
