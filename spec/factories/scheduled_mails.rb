# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :scheduled_mail do
    template_id 1
    send_at "2013-02-21 19:16:47"
    local_account_id ""
  end
end
