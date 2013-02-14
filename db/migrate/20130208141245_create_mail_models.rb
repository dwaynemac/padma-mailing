class CreateMailModels < ActiveRecord::Migration
  def change
    create_table :mail_models do |t|
      t.string :name
      t.string :description
      t.string :subject
      t.text :content
      t.integer :account_id

      t.timestamps
    end
  end
end
