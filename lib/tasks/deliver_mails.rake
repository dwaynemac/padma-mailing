desc 'Delivers scheduled_mails'
task :deliver_mails => :environment do
  ScheduledMail.pending.where('send_at < ?', Time.now).each do |mail|
    begin
      mail.deliver_now!
    rescue => e
      Rails.logger.warn "Failed delivering scheduled mail #{mail.id}: #{e.message}"
    end
  end
end
