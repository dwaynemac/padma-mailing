desc 'Delivers scheduled_mails'
task :deliver_mails => :environment do
  ScheduledMail.where('send_at < ?', Time.now).each do |mail|
    mail.deliver_now!
  end
end