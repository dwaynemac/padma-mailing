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
    @mailchimp_api ||= Gibbon::API.new api_key
  end

  # @return [Array <Hash>] lists
  def lists
    response = api.lists.list
    response["data"]
  end

  # @return [Hash] mailchimp response
  def subscribe(list_id, contacts)
    batch = contact.map do |c|
      {
        email: {email: c.email},
        FNAME: c.first_name,
        LNAME: c.last_name
      }
    end
    api.lists.batch_subscribe(id: list_id,
                              batch: batch,
                              update_existing: true,
                              double_optin: false
                             )
  end

  # @return [Hash] mailchimp response
  def unsubscribe(list_id, contacts)
    batch = contact.map do |c|
      {
        email: c.email,
      }
    end
    api.lists.batch_unsubscribe(id: list_id,
                                batch: batch,
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
end
