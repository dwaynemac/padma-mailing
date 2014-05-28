class AddCsvFileToImport < ActiveRecord::Migration
  def change
    add_attachment :imports, :csv_file
  end
end
