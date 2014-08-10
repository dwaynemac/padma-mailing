class AddContactSegmentIdToMailchimpSegment < ActiveRecord::Migration
  def change
    add_column :mailchimp_segments, :contact_segment_id, :string
  end
end
