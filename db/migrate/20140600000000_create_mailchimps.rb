class CreateMailchimps < ActiveRecord::Migration
  def change
    create_table :mailchimps do |t|
      t.string :list
    end
    create_table :segments do |t|
      t.integer :mailchimp_id
    end
    create_table :mailchimp_integrations, force: true do |t|
    end 
    create_table :lists do |t|
    end 
  end
end
