class AddCancelledToScheduledMail < ActiveRecord::Migration
  def change
    add_column :scheduled_mails, :cancelled, :boolean, default: false
  end
end
