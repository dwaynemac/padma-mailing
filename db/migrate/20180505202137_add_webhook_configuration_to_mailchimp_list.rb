class AddWebhookConfigurationToMailchimpList < ActiveRecord::Migration
  def change
    add_column :mailchimp_lists, :webhook_configuration, :text
  end
end
