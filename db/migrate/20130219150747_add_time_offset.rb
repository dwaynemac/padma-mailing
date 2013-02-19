class AddTimeOffset < ActiveRecord::Migration
  def change
    add_column :triggers, :offset_number, :integer
    add_column :triggers, :offset_unit, :string
    add_column :triggers, :offset_reference, :string
  end
end
