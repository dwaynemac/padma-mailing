class Ability
  include CanCan::Ability

  def initialize(user)
    self.merge GeneralAbility.new(user)

    # user can do everything on templates of his account.
    can :manage, Template, local_account_id: user.current_account_id
    can :manage, TemplatesFolder, local_account_id: user.current_account_id

    ##
    # Activities
    #
    can :update, ActivityStream::Activity, account_name: user.current_account.name, username: user.username
    # cannot :update, ActivityStream::Activity do |activity|
    #   (activity.updated_at.to_time < 1.day.ago) || (activity.local_deleted_object?)
    # end
    can :manage, Trigger, local_account_id: user.current_account_id
    can :manage, ScheduledMail, local_account_id: user.current_account_id


    can :read, PetalSubscription
    if admin?(user)
      can :create, PetalSubscription
      can :destroy, PetalSubscription
    end
  end
  
  private

  def alpha?(user)
    user.current_account.padma.try(:tester_level) == 'alpha'
  end

  def beta?(user)
    tl = user.current_account.padma.try(:tester_level)
    tl == 'alpha' || tl == 'beta'
  end


  def admin?(user)
    roles_for(user).include?('admin')
  end

  def roles_for(user)
    @roles_for_user ||= user.padma_roles_in(user.current_account.name)
    @roles_for_user || []
  end
end
