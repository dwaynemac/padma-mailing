class InterviewBookingDrop < Liquid::Drop
  def initialize(interview_on, padma_user, will_interview)
    @interview_on = ActiveSupport::TimeZone[Time.zone.name].parse(interview_on)
    @user = UserDrop.new(padma_user)
    @will_interview = UserDrop.new(will_interview)
  end

  def date
    @interview_on.to_date
  end

  def time
    @interview_on.to_time.strftime('%H:%M')
  end

  def instructor
    @will_interview
  end
end
