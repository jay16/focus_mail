#encoding:utf-8
module ApplicationHelper
  
  def full_title(page_title)
    base_title = "Focus Mail"
    if page_title.empty?
      base_title
    else
      %Q{#{base_title} | #{page_title}}
    end
  end

  def replace_email_source(campaign_id, member_id)
    campaign = Campaign.find(campaign_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{campaign.template.file_name}.html.erb")).join("").strip

    # replace all campaign_entries
    entries = campaign.valid_entries
    entries.each do |e|
      v = e.value
      # replace all links with virtual url
      if %r{^http://(.*)}.match(e.value)
        # create a link
        link = Link.where(:url => v).first_or_create
        v = "http://#{request.host}:#{request.port}/click?u=#{member_id}&c=#{campaign.id}&l=#{link.id}"
      end
      
      source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
      source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
      if(v.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
        source = source.gsub(/\$\|#{e.entry.name}\|\$/, v)
      else
        source = source.gsub(/\$\|#{e.entry.name}\|\$/, "http://#{request.host}:#{request.port}/images/" + v)
      end
    end

    source
  end
  
  def display_email(template_id,img_url)
    template = Template.find(template_id)
    if template.zip_url != nil then
      images = "/files/" + template.zip_url.to_s.split(".")[0] + "/images/"
    else
      images = "/images/"
    end
    entries = Entry.find_all_by_template_id(template_id)
    source_path = Rails.root.join('lib/emails', "#{template.file_name}.html.erb")
    if File.exist?(source_path)
      source = IO.readlines(source_path).join("").strip
      source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
      source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
      entries.each do |e|
        if e.name.include? "img" then
          if img_url == 1 then
            source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
          else
            if(e.default_value.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
              source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
            else
              source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{request.host}:#{request.port}#{images}" + e.default_value)
            end
          end
          
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    else
      source = "no email file!"
    end
    return source.lstrip
  end

  def get_campaign_summery(campaign_id)
    cam_summery = SendState.find(:last,
                       :select => "be_hits_number, be_hits_ratio, effective_operand_address, has_sent_number, open_number, open_ratio, reach_number, reach_ratio, send_ratio, total_address_number, campaign_id",
                       :conditions => ["send_states.campaign_id = ?", campaign_id])

   campaign = Campaign.find(campaign_id);
    if cam_summery != nil then
      pie = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart({:plotBackgroundColor=> '#FFFFFF' , 
          :height => 100,
          :width => 100,
          :plotShadow => false})
        f.title({:text=> ''})
        f.plotOptions({:pie=>{
            :allowPointSelect=> true , 
            :cursor=> 'pointer' , 
            :dataLabels=>{
              :enabled=> false , 
              :color=> '#000000' , 
              :connectorColor=> '#000000'}}})
        f.series({:type=>'pie' , :name=> 'Browser share' , 
            :data=> [
          ['back hard', cam_summery.effective_operand_address.to_i],
          ['back soft', cam_summery.reach_number.to_i],
          ['Reached', cam_summery.open_number.to_i],
          ['Account', cam_summery.be_hits_number.to_i]
        ]})
        f.tooltip({:enabled => false })
      end
        
      list_member = cam_summery.total_address_number
      send_totle = cam_summery.total_address_number#50000
      send_reach = cam_summery.reach_number#45000
      back_hard = cam_summery.reach_ratio#2100
      back_soft = cam_summery.open_ratio#1300
      open_num = cam_summery.open_number
      be_hits_number = cam_summery.be_hits_number
      account_erro = cam_summery.be_hits_ratio#1100
      back_other = cam_summery.effective_operand_address#500
     else
      list_member = 0
      send_totle = 0
      send_reach = 0
      back_hard = 0
      back_soft = 0
      open_num = 0
      cam_summery = 0
      be_hits_number = 0
      account_erro = 0
      back_other = 0
      pie = ''
     end
        
      @return = {:name => campaign.subject,
        :id => campaign.id,
        :list_member => list_member,
        :send_totle => send_totle,
        :pie => pie,
        :send_reach => send_reach,
        :back_hard => back_hard,
        :back_soft => back_soft,
        :open_num => open_num,
        :cam_summery => cam_summery,
        :click_num => be_hits_number,
        :account_erro => account_erro
        } 
     puts "*"*100
     puts @return.to_json
    @return 
  end
  
  def userorg_list(assetid, assettype)
      orglist = Array.new
      userorg = UserOrgObject.where(["asset_id = :uid and asset_type = 'User'", {:uid => assetid}]).first
      if userorg != nil then
        userorgs = UserOrgObject.where(["user_org_id = :uoid and asset_type = :ct ", {:uoid => userorg.user_org_id, :ct => assettype}]).all
        userorgs.each do |uo|
          orglist.push uo.asset_id
        end
      end
      return orglist
  end
  
  def user_action_org
    if user_signed_in?
      user_type = false
      user_id = current_user.id
      org_name = UserOrgObject.where(["asset_id = :u_id and asset_type = 'User'", {:u_id => user_id}]).last.user_org.name
      if org_name == "super" then
        user_type = true
      end
      return user_type
    end
  end
    
  def get_dashboard_data
    send_totle = 0
    send_reach = 0
    click_num = 0
    click_peo = 0
    open_num = 0
    open_peo = 0
    all_member = 0
    valid_member = 0
    
    #超级用户查看所有记录
    if user_action_org then
      DogData.all.each do |data|
        send_totle += data.send_num
        send_reach += data.send_ok
      end

      open_num  = Track.find_by_sql("select count(member_id) as COUNT from tracks")[0].COUNT
      click_num = Click.find_by_sql("select count(member_id) as COUNT from clicks")[0].COUNT
      
      all_member   = ListsMembers.select("count(distinct member_id) as COUNT")[0].COUNT
      valid_member = ListsMembers.select("count(distinct member_id) as COUNT")
                                 .where("member_id in (select members.id from members where members.type_email in (1,4,5))")[0].COUNT
    else
      #普通用户查看自己所有群组记录
      controller = "Campaign"
      cam_list = userorg_list(current_user.id, controller)
      DogData.all.each do |data|
        if cam_list.include?(data.campaign_id.to_i) then
          send_totle += data.send_num
          send_reach += data.send_ok
        end
      end
      
      controller = "List"
      list_list = userorg_list(current_user.id, controller)
      if list_list.empty?
        all_member = 0
        valid_member = 0
      else
        all_member = ListsMembers.select("count(distinct member_id) as count")
                       .where("list_id in (#{list_list.join(',')})")[0].count
        valid_member = ListsMembers.select("count(distinct member_id) as count")
                       .where("list_id in (#{list_list.join(',')}) and member_id in (select members.id from members where members.type_email in (1,4,5))")[0].count
      end
      
      if cam_list.present?
        open_num = Track.find_by_sql("select count(member_id) as COUNT from tracks where campaign_id in (#{cam_list.join(',')})")[0].COUNT
        click_num = Click.find_by_sql("select count(member_id) as COUNT from clicks where campaign_id in (#{cam_list.join(',')})")[0].COUNT
      end
    end

    @return = {
      :send_totle => send_totle,
      :send_reach => send_reach,
      :click_num => click_num,
      :click_peo => click_peo,
      :open_num  => open_num,
      :open_peo  => open_peo,
      :all_member => all_member,
      :valid_member => valid_member
    }
  end

=begin
  def get_campaign_report_by_id(id)
    #@campaign_id = id
    #@campaign_name = Campaign.find(@campaign_id).name
    #总名单人数
    @total_members = CampaignList.find(:all,
                     :select => "count(distinct members.id) AS MemberCount",
                     :joins => "LEFT JOIN members ON campaign_lists.list_id = members.list_id",
                     :conditions => ["campaign_lists.campaign_id = ?", @campaign_id])[0].MemberCount
    #总打开人数       
    @total_tracks = Track.find(:all,
                     :select => "count(distinct tracks.member_id) AS MemberCount",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击人数
    @total_clickers = Click.find(:all,
                     :select => "count(distinct clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击次数
    @total_clicks = Click.find(:all,
                     :select => "count(clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击次数
    @cam_summery = SendState.find(:last,
                     :select => "be_hits_number, be_hits_ratio, effective_operand_address, has_sent_number, open_number, open_ratio, reach_number, reach_ratio, send_ratio, total_address_number, campaign_id",
                     :conditions => ["send_states.campaign_id = ?", @campaign_id])[0].MemberCount

attr_accessible                 
    @report_array = Array.new
    @report_array.push(@campaign_name,@total_members,@total_tracks,@total_clickers,@total_clicks)
    
    return @report_array
  end
=end
  def get_category_summery(list,mos,lma)
    datas = []
    testnum = 0
    mos.each_with_index do |item,index|
      if index < 6 then
        datas.push([item.org_name,item.org_number])
      else
        testnum += item.org_number
      end
    end
    datas.push(["其他",testnum])
    @pie = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({:plotBackgroundColor=> :nil ,
        :backgroundColor=> :nil ,
        :height => 150,
        :width => 150,
        :plotShadow => false})
      f.title({:text=> ''})
      f.plotOptions({:pie=>{
          :allowPointSelect=> true , 
          :cursor=> 'pointer' , 
          :dataLabels=>{
            :enabled=> false , 
            :color=> '#000000' , 
            :connectorColor=> '#000000'}}})
      f.series({:type=>'pie' , :name=> '邮箱个数' , 
          :data=> datas})
      f.tooltip({:enabled => true })
    end
      
    @return = {:name => list.name,
      :id => list.id,
      :pie => @pie,
      :data_count => datas.count
      }
  end
  
  def split_string(str,len)
    astr = String.new
    count = str.length/len
    (0..count).each do |index|
      beg = index*len
      astr << str[beg,len]+"<br>"
    end
    return astr
  end
  
  def campaign_subject(c_id)
    Campaign.find(c_id).subject
  end
  
  def get_tcount_by_mid(c_id,m_id)
    Track.find(:all,:conditions => ["campaign_id = ? and member_id = ?",c_id,m_id]).length
  end
  
  def get_ccount_by_mid(c_id,l_id)
    Click.find(:all,:conditions => ["campaign_id = ? and link_id = ?",c_id,l_id]).length
  end

  def get_count_from_userorg(userorg_id)
   UserOrgObject.find_by_sql("select count(*) as userorg_count from user_org_objects where user_org_id=#{userorg_id} and asset_type='user';")[0].userorg_count
  end
  
  def g_chart(char_data)
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:height] = "100"
      f.options[:chart][:width] = "300"
      #f.options[:chart][:borderWidth] = "1"
      #f.options[:chart][:borderRadius ] = "20"
      #f.options[:chart][:borderColor] = "purple"
      f.options[:chart][:defaultSeriesType] = "area"
      f.options[:title][:text] = ""
      f.options[:xAxis][:labels] = {:enabled => false}
      f.options[:xAxis][:gridLineWidth] = 0
      f.options[:yAxis][:gridLineWidth] = 0
      f.options[:yAxis][:labels] = {:enabled => false}
      f.options[:yAxis][:title][:align] = "high"
      f.options[:yAxis][:labels][:overflow] = "justify"
      f.options[:chart][:renderTo] = "container"
      f.options[:chart][:type] = "bar"
      f.options[:legend][:layout] = "vertical"
      f.options[:legend][:align] = "right"
      f.options[:legend][:verticalAlign] = "top"
      f.options[:legend][:endabled] = false
      f.options[:legend][:x] = 10000
      f.plotOptions(:series=>{:dataLabels=>{:enabled => true }})
            f.tooltip(:formatter =>%|function() {
              if(this.series.name=='发送')
                ret = this.series.name + ':<b>'+this.y+'</b>封';
              if(this.series.name=='送达')
                ret = this.series.name + ':<b>'+this.y+'</b>封';
              if(this.series.name=='打开')
                ret = this.series.name + ':<b>'+this.y+'</b>次';
              if(this.series.name=='点击')
                ret = this.series.name + ':<b>'+this.y+'</b>次';
              return ret;}|.js_code)
      #f.series(:name=>"点击", :data=>[char_data[3]])
      f.series(:name=>"打开", :data=>[char_data[2]])
      f.series(:name=>"送达", :data=>[char_data[1]])
      f.series(:name=>"发送", :data=>[char_data[0]])
    end
  end
  
  #campaign是否发送
  def check_deliver(campaign_id)
    if campaign_id == nil then
      return 0
    else
      return ActionLog.where("asset_id = ? and action_name = 'Deliver'",campaign_id).count
    end
  end
  
end
