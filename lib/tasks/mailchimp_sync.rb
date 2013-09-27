namespace :mailchimp do

  desc 'sync all lists with mailchimp'
  task :sync => :environment do
    MailchimpIntegration.all.each do |m|
      puts "syncing #{m.account.name}"
      puts m.sync
    end
  end
end
