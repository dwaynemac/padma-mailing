class DropMailchimpIntegrations < ActiveRecord::Migration
  def up
    drop_table :mailchimp_integrations
  end

  def down
  end
end
