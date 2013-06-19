class Useradmin < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :type_user, :asset_id, :asset_type
  belongs_to :user, :class_name => "User", :primary_key => "id"
end
