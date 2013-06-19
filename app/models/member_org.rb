class MemberOrg < ActiveRecord::Base
  attr_accessible :name
  has_many :member_org_object
end
