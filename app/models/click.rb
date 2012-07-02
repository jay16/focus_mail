class Click < ActiveRecord::Base
  attr_accessible :campaign_id, :link_id, :member_id, :created_at, :updated_at
  belongs_to :campaign
  belongs_to :link
  belongs_to :member
end
