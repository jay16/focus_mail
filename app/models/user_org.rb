class UserOrg < ActiveRecord::Base
  attr_accessible :name, :user_id
  has_many :user_org_object
end
