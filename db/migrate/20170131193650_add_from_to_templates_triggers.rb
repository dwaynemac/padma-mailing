class AddFromToTemplatesTriggers < ActiveRecord::Migration
  def change
    add_column :templates_triggers, :from_display_name, :string
    add_column :templates_triggers, :from_email_address, :string
  end
end
