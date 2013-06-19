class Click < ActiveRecord::Base
  attr_accessible :campaign_id, :link_id, :member_id, :link_count, :created_at, :updated_at,:remote_ip,:browser
  belongs_to :campaign
  belongs_to :link
  belongs_to :member
end
