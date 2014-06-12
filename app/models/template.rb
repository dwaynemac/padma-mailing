class Template < ActiveRecord::Base
  attr_accessible :content, :description, :name, :subject, :attachments_attributes, :attachments

  validates_presence_of :subject
  validates_presence_of :name

  validates_presence_of :account
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

  has_many :templates_triggerses, dependent: :destroy, class_name: 'TemplatesTriggers'
  has_many :triggers, through: :templates_triggerses, class_name: 'TemplatesTriggers'
  has_many :attachments

  accepts_nested_attributes_for :attachments, :reject_if => lambda { |a| a[:file].nil? }, :allow_destroy => true

  def deliver(data)
    user = data[:user]
    schedule = ScheduledMail.create(
                                 send_at: Time.zone.now,
                                 template_id: self.id,
                                 local_account_id: user.current_account.id,
                                 recipient_email: data[:to],
                                 contact_id: data[:contact_id],
                                 username: user.username)
    schedule.deliver_now!
  end

  def self.tag_options_list
    tags={}

    time_slot_options = {"[Time Slot's Time]" => "%{time_slot.time}", "[Time Slot's Name]" => "%{time_slot.name}"}

    contact_options = {"[Contact's Full Name]" => "%{contact.full_name}",
                "[Contact's First Name]" => "%{contact.first_name}",
                "[Contact's Last Name]" => "%{contact.last_name}",
                "[Contact's Gender]" => "%{contact.gender}", 
                "[Contact's a_u_o]" => "%{contact.a_u_o}", 
                "[Contact's Instructor Name]" => "%{contact.instructor.name}", 
                "[Contact's Instructor Email]" => "%{contact.instructor.email}"}

    instructor_options = {"[Instructor's Name]" => "%{instructor.name}", 
                "[Instructor's email" => "%{instructor.email}"}

    trial_lesson_options = {"[Trial Lesson's Date]" => "%{trial_lesson.date}", 
                            "[Instructor's Trial Lesson's Name]" => "%{instructor.trial_lesson.name}",
                            "[Instructor's Trial Lesson's Email]" => "%{instructor.trial_lesson.email}",
                            "[Instructor's Time Slot Time]" => "%{instructor.time_slot.time}",
                            "[Instructor's Trial Lesson Name]" => "%{instructor.trial_lesson.name}"}
    tags.merge!(time_slot_options).merge!(instructor_options).merge!(contact_options).merge!(trial_lesson_options)
  end

  def self.convert_tag_into_liquid_format(new_snippet_value, search_by_key = true)
    search_by_key ? self.tag_options_list[new_snippet_value] : self.tag_options_list.invert[new_snippet_value]
  end

end
