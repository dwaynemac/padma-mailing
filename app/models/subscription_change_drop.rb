class SubscriptionChangeDrop < Liquid::Drop
  def initialize(attributes={})
    @contact = attributes[:contact]
    @contact_drop = attributes[:contact_drop]
    @instructor = attributes[:instructor]
    @instructor_drop = attributes[:instructor_drop]
  end
  
  def contact
    if @contact_drop
      @contact_drop
    else
      @contact_drop = ContactDrop.new(@contact,@instructor)
    end
  end
  
  def instructor
    if @instructor_drop
      @instructor_drop
    else
      @instructor_drop = UserDrop.new(@instructor)
    end
  end
end