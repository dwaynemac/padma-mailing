namespace :mailchimp do

  desc 'sync all lists with mailchimp'
  task :sync => :environment do
    MailchimpIntegration.all.each do |m|
      m.sync
    end
  end
end
