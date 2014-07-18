# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :segment do
    query "MyText"
    api_id "MyString"
  end
end
