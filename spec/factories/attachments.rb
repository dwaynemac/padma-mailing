# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do
    attachment_file_name "MyString"
    attachment_content_type "MyString"
    attachment_file_size 1
    attachment_updated_at "2013-03-03 19:53:49"
    template_id 1
  end
end
