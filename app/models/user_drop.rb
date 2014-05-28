class UserDrop < Liquid::Drop

  def initialize(padma_user)
    @padma_user = padma_user
  end

  def name
    @padma_user.user_name.split('.').map(&:camelcase).join(' ')
  end
  alias_method :nombre, :name

  def email
    @padma_user.email
  end
  alias_method :mail, :email

  #gender

  #firma

  #a_u_o
end