class AddNotificationsTypesToMailchimpList < ActiveRecord::Migration
  def change
    add_column :mailchimp_lists, :notifications_types, :string
  end
end
