class AddListIdToMailchimpSegment < ActiveRecord::Migration
  def change
    add_column :mailchimp_segments, :list_id, :string
  end
end
