class TimeSlotDrop < Liquid::Drop

  #For now we recieve the time and user, we should recieve the time_slot_id and get the values from the attendance module
  def initialize(trial_at, padma_user)
    @trial_at = DateTime.parse(@trial_at)
    @user = UserDrop.new(padma_user)
  end

  def time
    @trial_at.strftime("%H:%M")
  end
  alias_method :hora, :time

  #For now we use the time as name, this should change when we have a client to consume the attendance module
  alias_method :name, :time
  alias_method :nombre, :time
  
  def instructor
    @user
  end
end