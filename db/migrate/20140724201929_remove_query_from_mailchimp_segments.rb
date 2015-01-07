class RemoveQueryFromMailchimpSegments < ActiveRecord::Migration
  def change
    remove_column :mailchimp_segments, :query
  end
end
