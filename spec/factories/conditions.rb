# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :condition do
    key "MyString"
    value "MyString"
    scheduled_mail_id 1
  end
end
