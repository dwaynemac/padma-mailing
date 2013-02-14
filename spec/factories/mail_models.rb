# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mail_model do
    name "MyString"
    description "MyString"
    subject "MyString"
    content "MyText"
    account_id 1
  end
end
