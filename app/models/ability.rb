class Ability
  include CanCan::Ability

  def initialize(user)
    self.merge GeneralAbility.new(user)

    # user can do everything on templates of his account.
    can :manage, Template, local_account_id: user.current_account_id

    ##
    # Activities
    #
    can :update, ActivityStream::Activity, account_name: user.current_account.name, username: user.username
    # cannot :update, ActivityStream::Activity do |activity|
    #   (activity.updated_at.to_time < 1.day.ago) || (activity.local_deleted_object?)
    # end
    can :manage, Trigger, local_account_id: user.current_account_id
    can :manage, ScheduledMail, local_account_id: user.current_account_id

    can :create, PetalSubscription
  end
end
