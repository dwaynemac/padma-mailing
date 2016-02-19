class StoreMailchimpSubscriptionId < ActiveRecord::Migration
  def change
    add_column :mailchimp_configurations, :petal_subscription_id, :string
  end
end
