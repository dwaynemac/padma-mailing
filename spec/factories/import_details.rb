# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :import_detail do
    value { 1 } 
    import_id { 1 } 
    type { "" } 
    message { "MyText" } 
  end
end
