class AddDataToScheduledMail < ActiveRecord::Migration
  def change
  	add_column :scheduled_mails, :data, :text
  end
end
