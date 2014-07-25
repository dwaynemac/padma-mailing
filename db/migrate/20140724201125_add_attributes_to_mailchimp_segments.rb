class AddAttributesToMailchimpSegments < ActiveRecord::Migration
  def change
    add_column :mailchimp_segments, :student, :boolean
    add_column :mailchimp_segments, :exstudent, :boolean
    add_column :mailchimp_segments, :prospect, :boolean
    add_column :mailchimp_segments, :coefficient, :string
    add_column :mailchimp_segments, :only_man, :boolean
  end
end
