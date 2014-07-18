# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailchimp do
    api_key "MyString"
    list "MyString"
  end
end
