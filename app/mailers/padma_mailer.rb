# encoding: utf-8
class PadmaMailer < ActionMailer::Base
  require 'mail'

  def template(template, recipient, bcc, from)
    return if template.nil?
    return if recipient.blank?


    @recipients = recipient
    @bcc = bcc

    address = Mail::Address.new template.account.padma.email
    address.display_name = template.account.padma.full_name
    address.format

    @from =  address
    @subject = template.subject
    @sent_on = Time.zone.now
    @content = template.content
    template.attachments.each do |att|
      attachments[att.attachment_file_name] = File.read(att.attachment.path)
    end
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
