class UserDrop < Liquid::Drop

  def initialize(padma_user)
    @padma_user = padma_user
  end

  # TODO user has full_name now, use that instead.
  def name
    @padma_user.full_name
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