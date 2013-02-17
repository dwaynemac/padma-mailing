class PadmaMailer < ActionMailer::Base
  default from: "from@example.com"

  def mail_model(school, model, recipient, bcc=nil, from=nil)
    return if model.nil?
    return if recipient.blank?

    @recipients = recipient
    @bcc = bcc
    @from = (from.blank?)? "'#{model.school.name}' <#{model.school.email}>" : from
    @subject = model.subject
    @sent_on = Time.zone.now
    @content_type = 'multipart/mixed'
    part :content_type => "text/html", :body => render_message( 'mail_model',
                                                                :content => model.content,
                                                                :school => school )
  end
end
