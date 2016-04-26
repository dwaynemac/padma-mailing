class AddContactAttributesForMailchimpList < ActiveRecord::Migration
  def change
    add_column :mailchimp_lists, :contact_attributes, :string
  end
end
