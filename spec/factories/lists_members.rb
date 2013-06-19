# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lists_member, :class => 'ListsMembers' do
    list_id 1
    member_id 1
  end
end
