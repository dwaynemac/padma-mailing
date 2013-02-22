# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trigger do
    event_name 'event_name'
    account
  end
end
