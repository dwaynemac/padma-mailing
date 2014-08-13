class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :type
      t.integer :local_account_id
      t.string :status
      t.text :headers

      t.timestamps
    end
  end
end
