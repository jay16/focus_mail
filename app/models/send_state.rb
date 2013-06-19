class SendState < ActiveRecord::Base
  attr_accessible :be_hits_number, :be_hits_ratio, :effective_operand_address, :has_sent_number, :open_number, :open_ratio, :reach_number, :reach_ratio, :send_ratio, :total_address_number, :campaign_id, :created_at
  attr_accessible :track_no_click_count, :click_one_count, :click_many_count, :click_many_counts, :oneday, :onedaylast, :threedaylast, :sevenlast
end
