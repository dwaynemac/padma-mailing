class AddDeliveredAt < ActiveRecord::Migration
  def change
    add_column :scheduled_mails, :delivered_at, :timestamp
  end
end
