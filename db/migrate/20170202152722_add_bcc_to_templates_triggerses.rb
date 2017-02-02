class AddBccToTemplatesTriggerses < ActiveRecord::Migration
  def change
    add_column :templates_triggers, :bccs, :string
    add_column :scheduled_mails, :bccs, :string
  end
end
