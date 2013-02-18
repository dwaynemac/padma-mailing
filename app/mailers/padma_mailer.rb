class PadmaMailer < ActionMailer::Base
  default from: "afalkear@gmail.com"

  def mail_template(template, recipient, bcc=nil, from=nil)
    return if template.nil?
    return if recipient.blank?

    @recipients = recipient
    @bcc = bcc
    @from = (from.blank?)? "'#{template.account.name}' " : from
    @subject = template.subject
    @sent_on = Time.zone.now
    @content_type = 'multipart/mixed'
    mail( to: recipient,
          subject: @subject,
          content: template.content,
          template_path: 'padma_mailer',
          template_name: 'template')
  end
end
