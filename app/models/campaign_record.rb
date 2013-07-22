class CampaignRecord < ActiveRecord::Base
  attr_accessible :focus_server_id, :i, :info_json, :stage
  belongs_to :focus_server
end
