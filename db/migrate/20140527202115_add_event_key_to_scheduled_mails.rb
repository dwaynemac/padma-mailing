class AddEventKeyToScheduledMails < ActiveRecord::Migration
  def change
    add_column :scheduled_mails, :event_key, :string
  end
end
