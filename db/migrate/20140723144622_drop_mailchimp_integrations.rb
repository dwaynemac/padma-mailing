class DropMailchimpIntegrations < ActiveRecord::Migration
  def up
    drop_table :mailchimp_integrations if table_exists?(:mailchimp_integrations)
  end

  def down
  end
end
