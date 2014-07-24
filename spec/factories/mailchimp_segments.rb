# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailchimp_segment, :class => 'Mailchimp::Segment' do
    query "MyText"
    api_id "MyString"
    mailchimp_list_id 1
    name "MyString"
  end
end
