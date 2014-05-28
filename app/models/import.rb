class Import < ActiveRecord::Base
  attr_accessible :account_id, :csv_file, :headers, :status, :type
end
