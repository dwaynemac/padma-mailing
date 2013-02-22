class Template < ActiveRecord::Base
  # include RegistersActivity
  attr_accessible :content, :description, :name, :subject

  validates_presence_of :subject
  validates_presence_of :name

  validates_presence_of :account
  belongs_to :account, class_name: "Account", foreign_key: :local_account_id

  has_many :templates_triggerses, dependent: :destroy
  has_many :triggers, through: :templates_triggerses

  def creation_activity
    initialize_creation_activity(self.observations, {created_at: self.commented_at, updated_at: self.commented_at})
  end

  def deletion_activity
    initialize_deletion_activity(I18n.t('comment.deletion_activity', username: self.username))
  end

end
