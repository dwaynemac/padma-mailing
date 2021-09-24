# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :mailchimp_configuration, :class => 'Mailchimp::Configuration' do
    api_key { "MyString" } 
    local_account_id { 1 } 
    primary_list_id { 1 } 
  end
end
