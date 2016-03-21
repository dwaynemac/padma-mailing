class AddGenderToMailchimpSegments < ActiveRecord::Migration
  def change
    add_column :mailchimp_segments, :gender, :string
  end
end
