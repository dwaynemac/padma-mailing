class Account < ActiveRecord::Base
  # attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :templates, foreign_key: :local_account_id
  has_many :triggers, foreign_key: 'local_account_id'
  has_many :imports, foreign_key: :local_account_id

  has_one :mailchimp_configuration, foreign_key: :local_account_id, class_name: "Mailchimp::Configuration"
  has_many :templates_folders, foreign_key: :local_account_id, class_name: "TemplatesFolder"

  # Hook to Padma Account API
  # @param [TrueClass] cache: Specify if Cache should be used. default: true
  # @return [PadmaAccount]
  def padma(cache=true)
    api = (cache)? Rails.cache.read([self,"padma"]) : nil
    if api.nil?
      api = PadmaAccount.find(self.name)
    end
    Rails.cache.write([self,"padma"], api, :expires_in => 5.minutes) if !api.nil?
    return api
  end

  # Returns usernames of this account
  # @return [Array <String>]
  def usernames
    users = PadmaUser.paginate(account_name: self.name, per_page: 100)
    users.nil? ? nil : users.map(&:username)
  end
end
