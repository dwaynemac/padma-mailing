class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.string :description
      t.string :subject
      t.text :content
      t.integer :local_account_id

      t.timestamps
    end
  end
end
