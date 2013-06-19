class UserOrgObject < ActiveRecord::Base
  attr_accessible :asset_id, :asset_type, :user_org_id
  belongs_to :user_org
end
