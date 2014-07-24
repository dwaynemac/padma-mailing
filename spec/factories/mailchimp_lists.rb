# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailchimp_list, :class => 'Mailchimp::List' do
    api_id "MyString"
    mailchimp_configuration_id 1
    name "MyString"
  end
end
