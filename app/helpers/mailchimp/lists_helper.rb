module Mailchimp::ListsHelper
  def bootstrap_check_box_active (form_helper, method) 
    'active' if form_helper.object.send(method)
  end
  
  def bootstrap_radio_button_active (form_helper, method, value)
    'active' if form_helper.object.send(method) == value
  end
  
  def set_up (list)
    list = setup_students_segment(list)
    list = setup_formerstudents_segment(list)
    list = setup_maleexternal_segment(list)
    list = setup_prospects_p_segment(list)
    list
  end

  private

  def setup_students_segment(list)
    list.mailchimp_segments.build(student: true, name: 'students')
    list
  end

  def setup_formerstudents_segment(list)
    list.mailchimp_segments.build(coefficient: 'perfil', exstudent: true, name: 'former student')
    list
  end

  def setup_maleexternal_segment(list)
    list.mailchimp_segments.build(only_man: true, coefficient: 'perfil', exstudent: true, prospect: true, name: 'male external')
    list
  end

  def setup_prospects_p_segment(list)
    list.mailchimp_segments.build(coefficient: 'perfil', prospect: true, name: 'prospects p')
    list
  end
end
