# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :condition do
    key { "MyString" } 
    value { "MyString" } 
  end
end
