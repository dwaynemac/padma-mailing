class AddScheduledMailIdToCondition < ActiveRecord::Migration
  def change
    add_column :conditions, :scheduled_mail_id, :integer
  end
end
