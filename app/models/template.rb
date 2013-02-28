class Template < ActiveRecord::Base
  # include RegistersActivity

  attr_accessible :content, :description, :name, :subject

  validates_presence_of :subject
  validates_presence_of :name

  validates_presence_of :account
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

  has_many :templates_triggerses, dependent: :destroy
  has_many :triggers, through: :templates_triggerses

  def creation_activity(contact_id, user)
    #initialize_creation_activity("mail sent", {created_at: self.commented_at, updated_at: self.commented_at})
    ActivityStream::Activity.new(target_id: contact_id, target_type: 'Contact',
                                 object_id: self.id, object_type: 'Follow',
                                 generator: ActivityStream::LOCAL_APP_NAME,
                                 content: "mail sent",
                                 public: false,
                                 username: user.username,
                                 account_name: user.current_account.name,
                                 created_at: Time.zone.now.to_s ,
                                 updated_at: Time.zone.now.to_s )
  end

  # def deletion_activity
  #   initialize_deletion_activity("deleted")
  # end

  private
    def post_creation_activity
      a = creation_activity
      a.create(username: current_user.username, account_name: current_user.current_account.name)
    end

    # def post_deletion_activity
    #   a = deletion_activity
    #   a.create(username: self.username, account_name: self.account_name)
    # end
end
