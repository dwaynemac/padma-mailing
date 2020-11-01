# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :trigger do
    event_name { 'event_name' } 
    account
  end
end
