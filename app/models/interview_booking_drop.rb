class InterviewBookingDrop < Liquid::Drop
  def initialize(interview_on, padma_user, will_interview, timezone)
    @interview_on = DateTime.parse(interview_on)
    @user = UserDrop.new(padma_user)
    @will_interview = UserDrop.new(will_interview)
    @timezone = timezone
  end

  def date
    @interview_on.to_date
  end

  def time
    @interview_on.to_time.in_time_zone(@timezone).strftime('%H:%M')
  end

  def instructor
    @will_interview
  end
end
