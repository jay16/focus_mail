class LogAna < ActiveRecord::Base
  #attr_accessible :campaign_id, :member_num, :member_unvalid, :send_num, :send_ok, :track_num, :track_peo, :click_num, :click_peo
  attr_accessible :campaign_id, :data_type, :count
  #data_type:
  #1. 发送数量
  #2. 到达数量
  #3. 点击次数
  #4. 点击人数
  #5. 打开次数
  #6. 打开人数
end
