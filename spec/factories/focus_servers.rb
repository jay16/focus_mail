# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :focus_server do
    campaign_id 1
    send_type "MyString"
    file_name "MyString"
    stage 1
    info "MyString"
  end
end
