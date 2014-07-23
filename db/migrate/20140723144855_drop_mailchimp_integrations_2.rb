class DropMailchimpIntegrations2 < ActiveRecord::Migration
  def up
    drop_table :mailchimp_integrations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
