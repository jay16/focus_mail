# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :campaign_record do
    focus_server_id 1
    index 1
    stage 1
    info_json "MyText"
  end
end
