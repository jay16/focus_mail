class ActionLog < ActiveRecord::Base
  attr_accessible :action_datetime, :action_name, :asset_id, :asset_type, :user_id
end
