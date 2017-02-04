class UserDrop < Liquid::Drop

  def initialize(padma_user)
    @padma_user = padma_user
  end

  def name
    if @padma_user.full_name.blank?
      @padma_user.username.split('.').map(&:camelcase).join(' ')
    else
      @padma_user.full_name
    end
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