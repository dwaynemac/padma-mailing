# encoding: utf-8
class PadmaMailer < ActionMailer::Base
  require 'mail'
  require 'net/http'
  require 'uri'
  require 'open-uri'

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
      uri = att.attachment.s3_object(nil).url_for(:read, :secure => true).to_s
      attachments[att.attachment_file_name] = open(uri).read
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
