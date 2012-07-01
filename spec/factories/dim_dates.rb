# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dim_date do
    date_d "2012-07-01 17:41:49"
    date_s "MyString"
    date_Y 1
    date_q 1
    date_M 1
    date_w 1
    date_WN 1
  end
end
