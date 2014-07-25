module Mailchimp::ListsHelper
  def bootstrap_check_box_active (form_helper, method) 
    'active' if form_helper.object.send(method)
  end
  
  def bootstrap_radio_button_active (form_helper, method, value)
    'active' if form_helper.object.send(method) == value
  end
  
  def set_up (list)
    3.times {list.mailchimp_segments.build(coefficient: 'all')}
    list
  end
end
