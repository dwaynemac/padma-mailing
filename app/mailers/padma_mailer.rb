class PadmaMailer < ActionMailer::Base
  def template(template, recipient, bcc, from)
    return if template.nil?
    return if recipient.blank?

    @recipients = recipient
    @bcc = bcc
    @from = (from.blank?)? "'#{template.account.name}' " : from
    @subject = template.subject
    @sent_on = Time.zone.now
    @content = template.content
    mail( to: recipient,
          from: @from,
          subject: @subject,
          content: @content,
          template_path: 'padma_mailer',
          template_name: 'template') do |format|
      format.html
    end
  end
end
