class ContactDrop < Liquid::Drop

  def initialize(contact, user)
    @contact = contact
    @user_drop = UserDrop.new(user)
  end

  def full_name
    "#{@contact.first_name} #{@contact.last_name}"
  end
  alias_method :nombre_completo, :full_name

  def first_name
    @contact.first_name
  end
  alias_method :nombres, :first_name

  def last_name
    @contact.last_name
  end
  alias_method :apellidos, :last_name

  def gender
    @contact.gender.to_sym
  end
  alias_method :genero, :gender

  def a_u_o
    gender == :female ? 'a' : 'o'
  end

  def instructor
    @user_drop
  end

  #horario
    #horario.nombre, horario.hora, horario.instructor

  #plan_vigente
    #plan_vigente.nombre, plan_vigente.fecha_inicio, plan_vigente.fecha_fin
end