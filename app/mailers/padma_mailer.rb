# encoding: utf-8
class PadmaMailer < ActionMailer::Base
  require 'mail'
  require 'net/http'
  require 'uri'
  require 'open-uri'

  def template(template, data_hash, recipient, bcc, from_display_name=nil, from_email_address=nil)
    return if template.nil?
    return if recipient.blank?

    @recipients = recipient
    @bcc = bcc

    address = Mail::Address.new( from_email_address || template.account.padma.email )
    address.display_name = ( from_display_name || template.account.padma.full_name )
    @from =  address.format
    
    @subject = template.subject
    @sent_on = Time.zone.now
    @content = merge_content_data(template.content,data_hash)
    template.attachments.each do |att|
      uri = att.attachment.s3_object(nil).url_for(:read, secure: true).to_s
      attachments[att.attachment_file_name] = open(uri).read
    end
    mail( to: recipient,
          from: @from,
          bcc: @bcc,
          subject: @subject,
          content: @content,
          template_path: 'padma_mailer',
          template_name: 'template') do |format|
      format.html
    end
  end

  private

  def merge_content_data(content,data)
    Liquid::Template.parse(clean_snippets_html(content)).render(data)
  end

  def clean_snippets_html(content)
    content.gsub(/<div class=".*?-snippet" .*?>(.*?)<\/div>/,'\\1').gsub(/<div data-snippet="snippet_.*?" class=".*?-snippet">(.*?)<\/div>/,'\\1')
  end
end
