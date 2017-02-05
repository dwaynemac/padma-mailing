class TrialLessonDrop < Liquid::Drop

  def initialize(trial_at, padma_user, time_slot=nil)
    @trial_at = DateTime.parse(trial_at)
    @user = UserDrop.new(padma_user)
    if time_slot.nil?
      @time_slot = TimeSlotDrop.new(trial_at, padma_user)
    else
      time_slot_teacher = PadmaUser.find_with_rails_cache(time_slot.teacher)
      @time_slot = TimeSlotDrop.new(trial_at, time_slot_teacher)
    end
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