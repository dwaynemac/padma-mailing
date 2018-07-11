class InterviewBookingDrop < Liquid::Drop
  def initialize(interview_at, padma_user, will_interview)
    @interview_at = DateTime.parse(interview_at)
    @user = UserDrop.new(padma_user)
    @will_interview = UserDrop.new(will_interview)
  end

  def date
    @interview_at.to_date
  end

  def time
    @interview_at.to_time.strftime('%H:%M')
  end

  def instructor
    @will_interview
  end
end
