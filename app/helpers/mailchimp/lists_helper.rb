module Mailchimp::ListsHelper
  def bootstrap_check_box_active (form_helper, method) 
    'active' if form_helper.object.send(method)
  end
  
  def bootstrap_radio_button_active (form_helper, method, value)
    'active' if form_helper.object.send(method) == value
  end
  
  def set_up (list)
    if list.mailchimp_segments.empty?
      setup_students_segment(list)
      setup_formerstudents_segment(list)
      setup_maleexternal_segment(list)
      setup_prospects_p_segment(list)
    end
    list
  end

  private

  def setup_students_segment(list)
    list.mailchimp_segments.build(student: true, name: 'students')
  end

  def setup_formerstudents_segment(list)
    list.mailchimp_segments.build(coefficient: 'perfil', exstudent: true, name: 'former student')
  end

  def setup_maleexternal_segment(list)
    list.mailchimp_segments.build(only_man: true, coefficient: 'perfil', exstudent: true, prospect: true, name: 'male external')
  end

  def setup_prospects_p_segment(list)
    list.mailchimp_segments.build(coefficient: 'perfil', prospect: true, name: 'prospects p')
  end
end
