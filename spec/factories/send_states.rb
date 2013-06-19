# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :send_state do
    total_address_number 1
    effective_operand_address 1
    has_sent_number 1
    send_ratio 1
    reach_number 1
    reach_ratio 1
    open_number 1
    open_ratio 1
    be_hits_number 1
    be_hits_ratio 1
  end
end
