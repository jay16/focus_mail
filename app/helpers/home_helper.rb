module HomeHelper
  
    
  def get_campaign_data(campaign_id)
    send_totle = 0
    send_reach = 0
    click_num = 0
    click_peo = 0
    open_num = 0
    open_peo = 0
    isGetData = false
    if campaign_id != nil then
      data = DogData.select("sum(send_num) AS send_num,sum(send_ok) AS send_ok")
                    .where("campaign_id=#{campaign_id}").group("campaign_id")[0]
      #(:all, :conditions => ["log_anas.campaign_id = ?", campaign_id])
      if data.present?
        isGetData = true
        send_totle = data.send_num
        send_reach = data.send_ok
      end
        open_num = Track.find_by_sql("select count(member_id) as COUNT from tracks where campaign_id = #{campaign_id}")[0].COUNT
        open_peo = Track.find_by_sql("select count(distinct member_id) as COUNT from tracks where campaign_id = #{campaign_id}")[0].COUNT
        click_num = Click.find_by_sql("select count(member_id) as COUNT from clicks where campaign_id = #{campaign_id}")[0].COUNT
        click_peo = Click.find_by_sql("select count(distinct member_id) as COUNT from clicks where campaign_id = #{campaign_id}")[0].COUNT
      #ttmp = Track.find(:all,:conditions => ["campaign_id = ?",campaign_id]).length
      #ctmp = Click.find(:all,:conditions => ["campaign_id = ?",campaign_id]).length
    end
    
    @return = {
      :isGetData  => isGetData,
      :send_totle => send_totle,
      :send_reach => send_reach,
      :click_num => click_num,
      :click_peo => click_peo,
      :open_num  => open_num,
      :open_peo  => open_peo,
    }           
  end
end
