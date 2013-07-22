#encoding:utf-8
module ReportHelper
  
   #发送报告首页 数据收集
  def report_index(campaign_id)
    campaign = Campaign.find(campaign_id)
    clicks   = Click.select("count(member_id) as click_num,count(distinct member_id) as click_peo").where("campaign_id = #{campaign_id}")
    tracks   = Track.select("count(member_id) as track_num,count(distinct member_id) as track_peo").where("campaign_id = #{campaign_id}")
    #click_no_track = Click.find_by_sql("select count(distinct member_id) as num from clicks where campaign_id = 137 and member_id not in (select distinct member_id from tracks where campaign_id = 137);")
    send_num = 0
    send_ok  = 0 
    mem_num  = 0
    mem_valid = 0
    
    #list_list = userorg_list(current_user.id, "List")
    list_list = Array.new
    campaign.campaign_lists.each do |campaign_list|
      list_list.push(campaign_list.list_id)
    end
    if list_list.present?
      mem_num  = ListsMembers.select("count(distinct member_id) as member_num")
                 .where("list_id in (#{list_list.join(',')})")[0].member_num
      mem_valid =  ListsMembers.select("count(distinct member_id) as member_num")
                 .where("list_id in (#{list_list.join(',')}) and member_id in (select members.id from members where members.type_email in (1,4,5))")[0].member_num
    end
    
    dog_data = DogData.select("sum(send_num) AS send_num,sum(send_ok) AS send_ok")
                     .where("campaign_id=#{campaign_id}").group("campaign_id")[0]
    
    send_num = dog_data ? dog_data.send_num : 0
    send_ok  = dog_data ? dog_data.send_ok  : 0
            
          
     return {
       :campaign => campaign,
       :click_num => clicks[0].click_num,
       :click_peo => clicks[0].click_peo,
       :track_num => tracks[0].track_num,
       :track_peo => tracks[0].track_peo,
       :send_num  => send_num,
       :send_ok   => send_ok,
       :mem_num   => mem_num,
       :mem_valid => mem_valid
      }
  end
   
  def colina_hour(time_at)
     clicks_num = Colina.select("x,data").where("time_at = #{time_at} and type='click_num'")
     clicks_peo = Colina.select("x,data").where("time_at = #{time_at} and type='click_peo'")
     tracks_num = Colina.select("x,data").where("time_at = #{time_at} and type='click_num'")
     tracks_peo = Colina.select("x,data").where("time_at = #{time_at} and type='track_peo'")
     
    #x_label内为数字，x_index内为字符串
    x_label = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    x_index = %w(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
    
    click_num_data = Array.new
    click_peo_data = Array.new
    x_index.each_with_index do |data,index|
      tmp = clicks_num.select { |i| i.x == index }[0]
      click_num_data.push(tmp==nil ? 0 :tmp.data)
    end
    x_index.each_with_index do |data,index|
      tmp = clicks_peo.select { |i| i.x == index }[0]
      click_peo_data.push(tmp==nil ? 0 :tmp.data)
    end
    
    #以hour为维度，点击率=click_peo/track_peo
    track_num_data = Array.new
    track_peo_data = Array.new
    click_rate = Array.new
    x_index.each_with_index do |data,index|
      tmp = tracks_num.select { |i| i.x == index }[0]
      track_num_data.push(tmp==nil ? 0 :tmp.data)

    end
    
    x_index.each_with_index do |data,index|
      tmp = tracks_peo.select { |i| i.x == index }[0]
      track_peo_data.push(tmp==nil ? 0 :tmp.data)
      
      if track_peo_data[index] > 0 then
        rate = (Float(click_peo_data[index])*100/Float(track_peo_data[index])).round(2)
        click_rate.push(rate==nil ? 0 : rate)
      else
        click_rate.push(0)
      end
    end
    
    return x_index,click_num_data,track_num_data,click_rate,"hour"
  end

  
  #以week为维度获取click_num/click_peo/track_num/track_peo
  def colina_week(time_at)
     clicks_num = Colina.select("week,data").where("time_at = #{time_at} and type='week'")
     clicks_peo = Colina.select("week,data").where("time_at = #{time_at} and type='week'")
     tracks_num = Colina.select("week,data").where("time_at = #{time_at} and type='week_tracks'")
     tracks_peo = Colina.select("week,data").where("time_at = #{time_at} and type='week_tracks'")

    #x_label内为数字，x_index内为字符串
    x_label = [0,1,2,3,4,5,6]
    x_index = %w(0 1 2 3 4 5 6)
    x_name = %w(Sun Mon Tue Wed Thu Fri Sat)

    click_num_data = Array.new
    click_peo_data = Array.new
    x_index.each_with_index do |data,index|
      tmp = clicks_num.select { |i| i.week.to_i == index }[0]
      click_num_data.push(tmp==nil ? 0 :tmp.data)
    end
    x_index.each_with_index do |data,index|
      tmp = clicks_peo.select { |i| i.week.to_i == index }[0]
      click_peo_data.push(tmp==nil ? 0 :tmp.data)
    end
    
    
    #以week为维度，点击率=click_peo/track_peo
    track_num_data = Array.new
    track_peo_data = Array.new
    click_rate = Array.new
    x_index.each_with_index do |data,index|
      tmp = tracks_num.select { |i| i.week.to_i == index }[0]
      track_num_data.push(tmp==nil ? 0 :tmp.data)
    end
    
    x_index.each_with_index do |data,index|
      tmp = tracks_peo.select { |i| i.week.to_i == index }[0]
      track_peo_data.push(tmp==nil ? 0 :tmp.data)
      
      if track_peo_data[index] > 0 then
        rate = (Float(click_peo_data[index])*100/Float(track_peo_data[index])).round(2)
        click_rate.push(rate==nil ? 0 : rate)
      else
        click_rate.push(0)
      end
    end
    
    
    
    return x_name,click_num_data,track_num_data,click_rate,"week"
  end    
  
  #以hour为维度获取click_num/click_peo/track_num/track_peo
  def get_hour_data(campaign_id)
    clicks = Click.select("hour(created_at) as hour,count(*) as num,count(distinct member_id) as peo")
              .where("campaign_id=#{campaign_id}")
              .group("hour(created_at)")
              .order("hour(created_at) asc")
    tracks = Track.select("hour(created_at) as hour,count(*) as num,count(distinct member_id) as peo")
              .where("campaign_id=#{campaign_id}")
              .group("hour(created_at)")
              .order("hour(created_at) asc")
              
    #x_label内为数字，x_index内为字符串
    x_label = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    x_index = %w(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

    click_num_data = Array.new
    click_peo_data = Array.new
    x_index.each_with_index do |data,index|
      tmp = clicks.select { |i| i.hour == index }[0]
      click_num_data.push(tmp==nil ? 0 :tmp.num)
      click_peo_data.push(tmp==nil ? 0 :tmp.peo)
    end
    
    #以hour为维度，点击率=click_peo/track_peo
    track_num_data = Array.new
    track_peo_data = Array.new
    click_rate = Array.new
    x_index.each_with_index do |data,index|
      tmp = tracks.select { |i| i.hour == index }[0]
      track_num_data.push(tmp==nil ? 0 :tmp.num)
      track_peo_data.push(tmp==nil ? 0 :tmp.peo)
      
      if track_peo_data[index] > 0 then
        rate = (Float(click_peo_data[index])*100/Float(track_peo_data[index])).round(2)
        click_rate.push(rate==nil ? 0 : rate)
      else
        click_rate.push(0)
      end
    end
    
    return x_index,click_num_data,track_num_data,click_rate,"hour"
  end    
  
  #以week为维度获取click_num/click_peo/track_num/track_peo
  def get_week_data(campaign_id)
    clicks = Click.select("DATE_FORMAT(created_at,'%w') as week_index,count(*) as num,count(distinct member_id) as peo")
                  .where("campaign_id=#{campaign_id}")
                  .group("DATE_FORMAT(created_at,'%w')")
                  .order("DATE_FORMAT(created_at,'%w') asc")
    tracks = Track.select("DATE_FORMAT(created_at,'%w') as week_index,count(*) as num,count(distinct member_id) as peo")
                  .where("campaign_id=#{campaign_id}")
                  .group("DATE_FORMAT(created_at,'%w')")
                  .order("DATE_FORMAT(created_at,'%w') asc") 

    #x_label内为数字，x_index内为字符串
    x_label = [0,1,2,3,4,5,6]
    x_index = %w(0 1 2 3 4 5 6)
    x_name = %w(Sun Mon Tue Wed Thu Fri Sat)

    click_num_data = Array.new
    click_peo_data = Array.new
    x_index.each_with_index do |data,index|
      tmp = clicks.select { |i| i.week_index.to_i == index }[0]
      click_num_data.push(tmp==nil ? 0 :tmp.num)
      click_peo_data.push(tmp==nil ? 0 :tmp.peo)
    end
    
    #以week为维度，点击率=click_peo/track_peo
    track_num_data = Array.new
    track_peo_data = Array.new
    click_rate = Array.new
    x_index.each_with_index do |data,index|
      tmp = tracks.select { |i| i.week_index.to_i == index }[0]
      track_num_data.push(tmp==nil ? 0 :tmp.num)
      track_peo_data.push(tmp==nil ? 0 :tmp.peo)
      
      if track_peo_data[index] > 0 then
        rate = (Float(click_peo_data[index])*100/Float(track_peo_data[index])).round(2)
        click_rate.push(rate==nil ? 0 : rate)
      else
        click_rate.push(0)
      end
    end
    
    
    return x_name,click_num_data,track_num_data,click_rate,"week"
  end    
 
  #发送报告   点击、开信用户动作时间比例图表
  #以小时|星期为x坐标轴,左y轴显示数据，右y轴显示比率
  def g_chart_2y(datas)
    x_label,clicks,tracks,rate,type = datas
    
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:zoomType]       = "xy"
      f.options[:chart][:height]         = "500"
      f.options[:chart][:width]          = "800"
      
      f.options[:legend][:align]         = "center"
      f.options[:legend][:layout]        = "horizontal"
      f.options[:legend][:verticalAlign] = "bottom"
      f.options[:title][:text]           = (type == "hour" ? "开信、点击、点击率数据小时分布图" : '开信、点击、点击率数据星期分布图')
      f.options[:subtitle][:text]        = '2013-06-20 pm'
      
      f.xAxis(:categories=> x_label)
      f.yAxis([{
        :title => {
          :text => "Clicks|Tracks"
        }
        
      },{
        :title => {
          :text => "Clicks/Tracks"
        },
        :labels => {
          :formatter => %|function() {
                return this.value +'%';
            }|.js_code,
          :style => {
                :color => '#89A54E'
            }
        },
        :opposite => true
      }])
      
      #左y轴
      f.series({:name=> 'Clicks' , :type => 'column', :data=> clicks})
      f.series({:name=> 'Tracks' , :type => 'column', :data=> tracks})
      #右y轴
      f.series({:name=> 'Click Rate' , 
                :type => 'spline', 
                :yAxis => 1, 
                :tooltip => {
                    valueSuffix: ' %'
                },
                :data=> rate})
      f.tooltip({:enabled => true })
    end
  end     
  
   #发送报告   点击、开信图表，以小时为x坐标轴
   #点击、开信用户动作时间比例图表
  def g_chart_hour(clicks,tracks)
    x_label=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]

    click_data = Array.new
    (0..23).each_with_index do |index,no|
      tmp = clicks.select { |i| i.hour == index }[0]
      click_data.push(tmp==nil ? 0 :tmp.num)
    end
    
    track_data = Array.new
    (0..23).each_with_index do |index,no|
      tmp = tracks.select { |i| i.hour == index }[0]
      track_data.push(tmp==nil ? 0 :tmp.num)
    end

    
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:type] = "line"
      f.options[:chart][:height] = "500"
      f.options[:chart][:width] = "800"
      f.options[:legend][:align] = "center"
      f.options[:legend][:verticalAlign] = "bottom"
      f.options[:title][:text] = '开信、点击数据小时分布图'
      #鼠标悬停显示数据后缀
      #f.options[:tooltip][:valuePrefix] = "次"
      #f.options[:tooltip][:valueSuffix] = "次"


      f.xAxis(:categories=> x_label)
      f.series({:name=> '点击次数' , :data=> click_data})
      f.series({:name=> '开信次数' , :data=> track_data})
      f.tooltip({:enabled => true })
    end
  end
  
  #点击、开信用户邮箱域名比例图表
  def g_chart_domain(campaign_id,domain_type)
    if(domain_type=="track")
      array = Track.find(:all,
                   :select => "count(*) as count,right(members.email,length(members.email)-locate('@',members.email)) as domain",
                   :joins => "LEFT JOIN members ON tracks.member_id = members.id",
                   :conditions => ["tracks.campaign_id = ?", campaign_id],
                   :group => "right(members.email,length(members.email)-locate('@',members.email))",
                   :order => "count(*) desc")
                   
    else
      array = Click.find(:all,
                   :select => "count(*) as count,right(members.email,length(members.email)-locate('@',members.email)) as domain",
                   :joins => "LEFT JOIN members ON clicks.member_id = members.id",
                   :conditions => ["clicks.campaign_id = ?", campaign_id],
                   :group => "right(members.email,length(members.email)-locate('@',members.email))",
                   :order => "count(*) desc")
    end
    datas     = Array.new
    all_count = 0
    array.each do |track|
      datas.push([track.domain,track.count])
      all_count += track.count
    end
    #根据域名数量排名
    #datas.sort {|x,y| y[1] <=> x[1] }
    chart_data = Array.new
    rank_num   = 5
    
    if datas.length > rank_num then
      (0..rank_num-1).each do |index|
        chart_data.push(datas[index])
        all_count -= datas[index][1]
      end
      chart_data.push(["other",all_count])
    else
      chart_data = datas
    end

    h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:type] = "pie"
      f.options[:chart][:height] = "400"
      f.options[:chart][:width] = "550"
      f.options[:title][:text] = (domain_type == "track" ? '开信用户邮箱域名比例图' : '点击用户邮箱域名比例图')
      f.options[:legend][:align] = "center"
      f.options[:legend][:verticalAlign] = "top"

      f.tooltip({:pointFormat => '{series.name}: <b>{point.y}%</b>',
                 :percentageDecimals => 1})
      f.plotOptions({:pie => { :allowPointSelect => true,
                               :cursor => 'pointer',
                               :dataLabels => { :enabled => true,
                                                :color => '#000000',
                                                :connectorColor => '#000000',
                                                :percentageDecimals => 1,
                                                :formatter => %|function(){
                                                  return '<b>'+ this.point.name +'</b> '+ Highcharts.numberFormat(this.percentage,2) +' %';
                                                }|.js_code
                                               }
                              }
                      })   
      f.series({:type => "pie",
                :name => "域名比例",
                :data => chart_data})


      f.tooltip({:enabled => true })
    end
  
  end
 #有效名单域名比例
  def g_chart_member(campaign_id)
    campaign = Campaign.find(campaign_id)
    campaign_lists = campaign.campaign_lists
    lists = Array.new
    campaign_lists.each do |cl|
      lists.push(cl.list_id)
    end
    
    array = ListsMembers.find(:all,
                 :select => "count(*) as count,lower(right(members.email,length(members.email)-locate('@',members.email))) as dd",
                 :joins => "LEFT JOIN members ON lists_members.member_id = members.id",
                 :conditions => ["lists_members.list_id in (#{lists.join(',')})"],
                 :group => "lower(right(members.email,length(members.email)-locate('@',members.email)))",
                 :order => "count(*) desc")

    datas     = Array.new
    all_count = 0
    array.each do |data|
      datas.push([data.dd,data.count])
      all_count += data.count
    end
    #根据域名数量排名 select中已排序
    #datas.sort {|x,y| y[1] <=> x[1] }
    chart_data  = Array.new
    rank_num    = 10
    
    if datas.length > rank_num then
      (0..rank_num-1).each do |index|
        chart_data.push(datas[index])
        all_count -= datas[index][1]
      end
      chart_data.push(["other",all_count])
    else
      chart_data = datas
    end
    
    h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:type] = "pie"
      f.options[:chart][:height] = "500"
      f.options[:chart][:width] = "800"
      f.options[:title][:text] = '该活动涉及名单中有效名单域名比例图'
      f.options[:legend][:align] = "center"
      f.options[:legend][:verticalAlign] = "top"

      f.tooltip({:pointFormat => '{series.name}: <b>{point.y}</b>',
                 :percentageDecimals => 1})
      f.plotOptions({:pie => { :allowPointSelect => true,
                               :cursor => 'pointer',
                               :dataLabels => { :enabled => true,
                                                :color => '#000000',
                                                :connectorColor => '#000000',
                                                :percentageDecimals => 1,
                                                :formatter => %|function(){
                                                  return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage,2) +' %';
                                                }|.js_code
                                               }
                              }
                      })   
      f.series({:type => "pie",
                :name => "域名比例",
                :data => chart_data })


      f.tooltip({:enabled => true })
    end
    
  end
  
   #点击、开信用户浏览器比例图表
  def g_chart_browser(campaign_id,type)
    
    if type == "track" then
      tracks = Track.select("browser")
                .where("campaign_id=#{params[:c_id]}")
      chart_title = '开信用户浏览器使用比例图'
    else
      tracks = Click.select("browser")
                .where("campaign_id=#{params[:c_id]}")
      chart_title = '点击用户浏览器使用比例图'
    end
    #click = Click.select("browser")
    #          .where("campaign_id=#{params[:c_id]} and member_id not in (select tracks.member_id where tracks.campaign_id = #{params[:c_id]}")
    
    browsers = Array.new
    keywords = %w(iphone ipad android firefox chrome safari msie opera maxthon theworld netscape )
    keynames = %w(iphone ipad android Firefox Chrome Safari IE Opera Maxthon TheWorld Netscapt )
    
    keywords.each_with_index do |key,index|
      browsers.push({:key => key,:keyname => keynames[index],:count => 0})
    end
    
    all_count = tracks.count
    count     = 0
    tracks.each do |track|
      browser = track.browser
      next unless browser
      browser.downcase!
      browsers.each do |b|
        if browser.include?(b[:key]) then
          b[:count] += 1
          count     += 1
          break
        end
      end
    end
    
    browsers.select! { |b| b[:count] > 0 }
    browsers.sort! { |a,b| b[:count] <=> a[:count] }
    
    chart_data = Array.new
    browsers.each do |b|
      chart_data.push([b[:keyname],b[:count]])
    end
    chart_data.push(["Other",all_count-count])
    
    
    h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:type] = "pie"
      f.options[:chart][:height] = "400"
      f.options[:chart][:width] = "550"
      f.options[:title][:text] = chart_title
      f.options[:legend][:align] = "center"
      f.options[:legend][:verticalAlign] = "top"

      f.tooltip({:pointFormat => '{series.name}: <b>{point.y}%</b>',
                 :percentageDecimals => 0,
                 :valueDecimals => 2})
      f.plotOptions({:pie => { :allowPointSelect => true,
                               :cursor => 'pointer',
                               :dataLabels => { :enabled => true,
                                                :color => '#000000',
                                                :connectorColor => '#000000',
                                                :valueDecimals => 1,
                                                :formatter => %|function(){
                                                  return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage,2) +' %';
                                                }|.js_code
                                               }
                        
                              },
                      :series => {:cursor  => 'pointer',
                                  :events => {
                                        :click => %|function(event) {
                                             alert(event.point.name+'-'+event.point.y+'-More Functions is Developping!');
                                             //跳转页面
                                             //location.href='http://www.baidu.com';
                                               }|.js_code
                                             }
                                   }
                      })
      
      f.series({:type => "pie",
                :name => "browser share",
                :data => chart_data })


      f.tooltip({:enabled => true })
    end
  end
   #点击、开信用户地域比例图表
  def g_chart_usermap(campaign_id)

    h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:type] = "pie"
      f.options[:chart][:height] = "500"
      f.options[:chart][:width] = "800"
      f.options[:title][:text] = '开信用户城市分布比例图'
      f.options[:legend][:align] = "center"
      f.options[:legend][:verticalAlign] = "top"

      f.tooltip({:pointFormat => '{series.name}: <b>{point.percentage}%</b>',
                 :percentageDecimals => 1})
      f.plotOptions({:pie => { :allowPointSelect => true,
                               :cursor => 'pointer',
                               :dataLabels => { :enabled => true,
                                                :color => '#000000',
                                                :connectorColor => '#000000',
                                                :percentageDecimals => 1,
                                                :formatter => %|function(){
                                                  return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage,2) +' %';
                                                }|.js_code
                                               }
                              }
                      })   
      f.series({:type => "pie",
                :name => "browser share",
                :data => [['上海',45.0],
                          ['江苏',24],
                          {:name => '广州',
                           :y    => 11,
                           :sliced => true,
                           :selected => true},
                           ['浙江',8.2],
                           ['南京',5.8],
                           ['其他',6]]})


      f.tooltip({:enabled => true })
    end
  end
  
  #获取开信、点击用户客户端浏览器信息
  #cid - campaign_id
  #mid - member_id
  def browser_info(cid,mid,type)
    browsers = (type == "track" ?
    Track.where("campaign_id = :cid and member_id = :mid",:cid => cid,:mid => mid )
    :
    Click.where("campaign_id = :cid and member_id = :mid",:cid => cid,:mid => mid )
    )
    
    browser = String.new
    browsers.each do |info|
      tmp = info.browser
      browser = tmp if tmp.length > browser.length
    end 
    
    keywords = ["iphone","ipad","android","firefox","chrome","safari","msie 6.0","msie 7.0","msie 8.0","msie 9.0","msie 10.0","msie","opera","etscape"]
    keynames = %w(iphone ipad android Firefox Chrome Safari IE6 IE7 IE8 IE9 IE10 IE Opera Netscapt)
   
    keyname = String.new
    keywords.each_with_index do |key,index|
        if browser.downcase.include?(key) then
          keyname = keynames[index]
          break
        end
    end

    keyname = (keyname.present? ? keyname : "other")
    return keyname,browser
  end
end
