class TrialLessonDrop < Liquid::Drop

  def initialize(trial_at, padma_user)
    @trial_at = DateTime.parse(@trial_at)
    @user = UserDrop.new(padma_user)
    #For now we use the time and user, we should use the time_slot_id
    @time_slot = TimeSlotDrop.new(trial_at, padma_user)
  end

  def date
    @trial_at.to_date
  end
  alias_method :dia, :date

  def time_slot
    @time_slot
  end
  alias_method :horario, :time_slot
  
  def instructor
    @user
  end
end