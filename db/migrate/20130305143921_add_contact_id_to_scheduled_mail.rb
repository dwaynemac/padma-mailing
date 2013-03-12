class AddContactIdToScheduledMail < ActiveRecord::Migration
  def change
    add_column :scheduled_mails, :contact_id, :string
    add_column :scheduled_mails, :username, :string
  end
end
