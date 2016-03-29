class AddFollowedByToSegment < ActiveRecord::Migration
  def change
    add_column :mailchimp_segments, :followed_by, :string
  end
end
