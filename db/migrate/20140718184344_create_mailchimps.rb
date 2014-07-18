class CreateMailchimps < ActiveRecord::Migration
  def change
    create_table :mailchimps do |t|
      t.string :api_key
      t.string :list

      t.timestamps
    end
  end
end
