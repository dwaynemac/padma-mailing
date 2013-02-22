class CreateScheduledMails < ActiveRecord::Migration
  def change
    create_table :scheduled_mails do |t|
      t.integer  :template_id
      t.integer  :local_account_id

      t.string   :recipient_email

      t.datetime :send_at

      t.timestamps
    end
  end
end
