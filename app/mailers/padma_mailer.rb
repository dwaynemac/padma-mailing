class PadmaMailer < ActionMailer::Base
  default from: "from@example.com"

  def single_mail(email, subject, content)
    @greeting = content
    mail to: email, subject: subject
  end
end
