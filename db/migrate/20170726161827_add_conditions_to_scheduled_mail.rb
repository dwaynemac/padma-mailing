class AddConditionsToScheduledMail < ActiveRecord::Migration
  def change
    add_column :scheduled_mails, :conditions, :text
  end
end
