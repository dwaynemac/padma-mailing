class NextActionDrop < Liquid::Drop
  def initialize(action_on, padma_user, will_interview, timezone)
    @action_on = DateTime.parse(action_on)
    @user = UserDrop.new(padma_user)
    @will_interview = UserDrop.new(will_interview)
    @timezone = timezone
  end

  def date
    @action_on.to_date
  end

  def time
    @action_on.to_time.in_time_zone(@timezone).strftime('%H:%M')
  end

  def instructor
    @will_interview
  end
end
