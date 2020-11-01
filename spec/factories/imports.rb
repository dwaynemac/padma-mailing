# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :import do
    type { "" } 
    account_id { 1 } 
    status { "MyString" } 
    headers { "MyText" } 
    csv_file { "MyString" } 
  end
end
