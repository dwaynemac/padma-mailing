class AddReceiveNotificationsToMailchimpList < ActiveRecord::Migration
  def change
    add_column :mailchimp_lists, :receive_notifications, :boolean, :default => true
  end
end
