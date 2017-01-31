class AddFromAddressToScheduledMails < ActiveRecord::Migration
  def change
    add_column :scheduled_mails, :from_display_name, :string
    add_column :scheduled_mails, :from_email_address, :string
  end
end
