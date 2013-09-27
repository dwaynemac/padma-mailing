class AccountMailchimpApiKey < ActiveRecord::Migration
  def change
    add_column :accounts, :mailchimp_api_key, :string
  end
end
