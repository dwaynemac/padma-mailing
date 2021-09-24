# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :scheduled_mail do
    template_id { 1 } 
    recipient_email { 'dwaynemac@gmail.com' } 
    send_at { "2013-02-21 19:16:47" } 
    account
  end
end
