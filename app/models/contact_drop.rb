class ContactDrop < Liquid::Drop

  def initialize(contact)
    puts "initialize"
    @contact = contact
  end

  def nombre_completo
    "#{@contact.first_name} #{@contact.last_name}"
  end

  def nombres
    @contact.first_name
  end

  def apellidos
    @contact.last_name
  end
end