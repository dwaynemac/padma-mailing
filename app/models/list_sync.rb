class ListSync < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :mailchimp_list_id, :local_list_name, :local_account_id

  belongs_to :account, foreign_key: :local_account_id

  validates_uniqueness_of :mailchimp_list_id, scope: :local_account_id

end
