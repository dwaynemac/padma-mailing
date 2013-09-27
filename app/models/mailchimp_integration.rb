class MailchimpIntegration < ActiveRecord::Base
  attr_accessible  :students_list_id
  attr_accessible  :p_former_students_list_id
  attr_accessible  :p_prospects_list_id
  attr_accessible  :p_nonstudents_list_id
  attr_accessible  :all_nonstudents_list_id
  attr_accessible  :all_list_id

  belongs_to :account, foreign_key: :local_account_id
  validates_presence_of :api_key

  # @return [Gibbon:API]
  def api
    if @mailchimp_api.nil?
      @mailchimp_api = Gibbon::API.new api_key
      @mailchimp_api.throws_exceptions = false
    end
    @mailchimp_api
  end

  # @return [Array <Hash>] lists
  def lists
    response = api.lists.list
    if response["status"] == "error"
      nil
    else
      response["data"]
    end
  end

  def sync
    unless students_list_id.blank?
      subscribe(students_list_id, students)
      unsubscribe(students_list_id, former_students)
    end

    unless p_former_students_list_id.blank?
      subscribe(p_former_students_list_id, p_former_students)
      unsubscribe(p_former_students_list_id, students)
    end

    unless all_list_id.blank?
      subscribe(all_list_id, all)
    end
  end

  # @return [Hash] mailchimp response
  def subscribe(list_id, contacts)
    batch = contacts.map do |c|
      if c.email
        {
          email: {email: c.email},
          FNAME: c.first_name,
          LNAME: c.last_name
        }
      end
    end
    api.lists.batch_subscribe(id: list_id,
                              batch: batch.compact,
                              update_existing: true,
                              double_optin: false
                             )
  end

  # @return [Hash] mailchimp response
  def unsubscribe(list_id, contacts)
    batch = contacts.map do |c|
      if c.email
        {
          email: c.email,
        }
      end
    end
    api.lists.batch_unsubscribe(id: list_id,
                                batch: batch.compact,
                                delete_member: false,
                                send_goodbay: false,
                                send_notify: false)
  end

  # @return [Boolean]
  def contact_in_list?(list_id, contact)
    list_emails = list_members(list_id).map{|member| member["email"]}
    list_emails.include?(contact.email)
  end

  # @return [Array <Hash>] members
  def list_members(list_id)
    members = instance_variable_get("@list_#{list_id}")
    if members.nil?
      instance_variable_set("@list_#{list_id}",api.lists.members(id: list_id)["data"])
      members = instance_variable_get("@list_#{list_id}")
    end
    members
  end

  def students
    @students ||= PadmaContact.search(account_name: self.account.name, where: {local_status: 'student'})
  end

  def former_students
    @former_students ||= PadmaContact.search(account_name: self.account.name, where: {local_status: 'former_student'})
  end

  def p_former_students
    @p_former_students ||= PadmaContact.search(account_name: self.account.name, where: {local_status: 'former_student', local_coefficient: %W(pmenos perfil pmas)})
  end

  def all
    @all ||= PadmaContact.search(account_name: self.account.name)
  end
end
