class Track < ActiveRecord::Base
  attr_accessible :campaign_id, :member_id, :created_at, :updated_at
  belongs_to :campaign
  belongs_to :member
end
