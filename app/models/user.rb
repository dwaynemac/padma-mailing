class User < ActiveRecord::Base
  attr_accessible :username

  include Accounts::IsAUser

  devise :cas_authenticatable

  validates_uniqueness_of :username
  validates_presence_of :username

  belongs_to :current_account, :class_name => "Account"

  # Accounts::IsAUser needs class to respond_to account_name
  def account_name
    self.current_account.try :name
  end

  # Accounts::IsAUser needs class to respond_to account_name=
  def account_name=(name)
    self.current_account = Account.find_by_name(name)
  end

  # Accounts::IsAUser needs class to respond_to account_name_changed?
  def account_name_changed?
    self.current_account_id_changed?
  end

  # Returns roles in given accounts
  # @param account_name [String]
  # @return [Array]
  def padma_roles_in(account_name)
    p = self.padma
    if p && p.roles
      p.roles.select{|r|r['account_name'] == account_name}.map{|r|r['name']}
    end
  end

end
