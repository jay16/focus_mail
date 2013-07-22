class UserOrgObject < ActiveRecord::Base
  attr_accessible :asset_id, :asset_type, :user_org_id
  belongs_to :user_org
  
  #字段说明(对用户，发送活动，模板，名单列表所属用户或群级划分)
  #asset_id     类型id:          用户id  campaign_id  template_id  list_id
  #asset_type   类型:            user    campaign     template     list
  #user_org_id  用户所属群组id
end
