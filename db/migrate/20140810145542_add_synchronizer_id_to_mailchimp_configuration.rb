class AddSynchronizerIdToMailchimpConfiguration < ActiveRecord::Migration
  def change
    add_column :mailchimp_configurations, :synchronizer_id, :string
  end
end
