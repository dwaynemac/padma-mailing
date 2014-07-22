class AddNameToSegment < ActiveRecord::Migration
  def change
    add_column :segments, :name, :string
  end
end
