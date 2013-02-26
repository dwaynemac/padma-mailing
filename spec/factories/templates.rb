# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence(:random_string) {|n| "name#{n}" }

  factory :template do
    name { generate(:random_string) }
    description 'asdf'
    subject 'asdfasd'
    content 'asfasd'
    account
  end
end
