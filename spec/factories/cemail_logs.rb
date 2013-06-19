# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cemail_log do
    template_id 1
    from_email "MyString"
    to_eamil "MyString"
    subject "MyString"
  end
end
