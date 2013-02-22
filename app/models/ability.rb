class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # user can do everything on templates of his account.
    can :manage, Template, local_account_id: user.current_account_id

    ##
    # Activities
    #
    can :update, ActivityStream::Activity, account_name: user.current_account.name, username: user.username
    cannot :update, ActivityStream::Activity do |activity|
      (activity.updated_at.to_time < 1.day.ago) || (activity.local_deleted_object?)
    end
    can :manage, Trigger, local_account_id: user.current_account_id
    can :manage, ScheduledMail, local_account_id: user.current_account_id
  end
end
