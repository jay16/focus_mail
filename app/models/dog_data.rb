class DogData < ActiveRecord::Base
  attr_accessible :campaign_id, :member_num, :member_unvalid, :send_num, :send_ok, :track_num, :track_peo
  attr_accessible :click_num, :click_peo,:time_tag
end
