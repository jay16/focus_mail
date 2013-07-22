class FocusServer < ActiveRecord::Base
  attr_accessible :campaign_id, :file_name, :info, :send_type, :stage
  has_many :campaign_records
end
