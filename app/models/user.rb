class User < ActiveRecord::Base
  attr_accessible :username

  include Accounts::IsAUser

  devise :cas_authenticatable

  validates_uniqueness_of :username
  validates_presence_of :username

end
