# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :filter do
    trigger_id { 1 } 
    key { "MyString" } 
    value { "MyString" } 
  end
end
