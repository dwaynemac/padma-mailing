# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :account do
    name { generate(:random_string) }
  end
end
