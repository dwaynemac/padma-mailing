class AddFilterMethodToMailchimpConfiguration < ActiveRecord::Migration
  def change
    add_column :mailchimp_configurations, :filter_method, :string
  end
end
