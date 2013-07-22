class Useradmin < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :type_user, :asset_id, :asset_type
  belongs_to :user, :class_name => "User", :primary_key => "id"
  
  #字段说明（用户对Campaigns,Templates,Reports,Categories使用权限的设定）
  #asset_type: Supers Campaigns Templates Reports Categories
  #asset_id:   用户id
  #type_user:  1 - 用户拥有asset_type对应的权限；0 - 没有该权限
end
