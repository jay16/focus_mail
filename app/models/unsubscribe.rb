class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :campaign_id, :reason, :created_at

end
