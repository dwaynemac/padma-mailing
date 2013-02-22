class CreateTemplatesTriggers < ActiveRecord::Migration
  def change
    create_table :templates_triggers do |t|
      t.integer :template_id
      t.integer :trigger_id
    end
  end
end
