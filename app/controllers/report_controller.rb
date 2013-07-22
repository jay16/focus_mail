#encoding: utf-8
class ReportController < ApplicationController
  require "will_paginate/array"
  layout "win8_layout"
  
  #发送报告首页
  def index
   @campaign = Campaign.find(params[:c_id])

    respond_to do |format|
      format.html
    end
  end
  
  #开信用户数据
  def tracks
    if params[:c_id].present?
      #@tracks = Track.includes(:member,:campaign).order("created_at desc").paginate(:conditions => ["campaign_id = ?", params[:c_id]],:page => params[:page], :per_page => 20)
      @tracks = Track.includes(:member,:campaign)
                      .select("campaign_id,member_id,count(*) as count,max(created_at) as last_at")
                      .group("member_id")
                      .where("campaign_id = ?",params[:c_id])
                      .paginate(:page => params[:page],:per_page => 40, :order => "last_at desc")
                      
      @track_data = Track.select("count(member_id) as track_num,count(distinct member_id) as peo_num").where("campaign_id = ?",params[:c_id])[0]
    else
      @tracks = Track.includes(:member,:campaign)
                      .select("campaign_id,member_id,count(*) as count,max(created_at) as last_at")
                      .group("member_id")
                      .paginate(:page => params[:page],:per_page => 40, :order => "last_at desc")
                      
      @track_data = Track.select("count(member_id) as track_num,count(distinct member_id) as peo_num")[0]      
    end     
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracks }
    end
  end
  
  #点击用户数据
  def clicks
   if params[:l_id].present? and params[:c_id].present?
     @clicks = Click.includes(:member, :campaign, :link)
                    .select("member_id,campaign_id,link_id,count(*) as count,max(updated_at) as last_at")
                    .group("member_id,link_id")
                    .order("max(updated_at) desc")
                    .where("campaign_id = ? and link_id = ?",params[:c_id],params[:l_id])
                    .paginate(:page => params[:page],:per_page => 20, :order => "last_at desc")
     @click_data = Click.select("count(member_id) as click_num,count(distinct member_id) as peo_num")
                    .where("campaign_id = ? and link_id = ?",params[:c_id],params[:l_id])[0]
   elsif params[:c_id].present?
     #@clicks = Click.includes(:member, :campaign, :link).order("member_id desc").paginate(:page => params[:page], :per_page => 20 ,:conditions  => ["campaign_id = ?", params[:c_id]])
     @clicks = Click.includes(:member, :campaign, :link)
                    .select("member_id,campaign_id,link_id,count(*) as count,max(updated_at) as last_at")
                    .group("member_id,link_id")
                    .order("max(updated_at) desc")
                    .where("campaign_id=?",params[:c_id])
                    .paginate(:page => params[:page],:per_page => 100, :order => "last_at desc")
                    
      @click_data = Click.select("count(member_id) as click_num,count(distinct member_id) as peo_num")
                    .where("campaign_id = ?",params[:c_id])[0]
   else
     @clicks = Click.includes(:member, :campaign, :link)
                    .select("member_id,campaign_id,link_id,count(*) as count,max(updated_at) as last_at")
                    .group("member_id,link_id")
                    .order("max(updated_at) desc")
                    .paginate(:page => params[:page],:per_page => 20, :order => "last_at desc")
                    
     @click_data = Click.select("count(member_id) as click_num,count(distinct member_id) as peo_num")[0]
   end
    
    user_action_log(0,params[:controller],"index")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clicks }
    end
  end
  
  #在模板中显示链接点击次数
  def templates
    @c_id = params[:c_id]
    template= Rails.root.join("app","views","report","templates","#{@c_id}.html.erb")
    @c_id = -1 unless File.exists?(template)
    
    respond_to do |format|
      format.html
    end    
  end
  
  #点击、开信用户动作时间比例图表
  def time
                   
  end
  
  #名单管理；有效名单、无效名单、域名比例
  def member
    
  end
  
  #发送信综合数据
  def datas
    if params[:c_id].present?
      @report = DogData.select("sum(send_num) AS send_num,sum(send_ok) AS send_ok")
                       .where("campaign_id=#{params[:c_id]}").group("campaign_id")[0]
      @campaign = Campaign.find(params[:c_id])
      @bi_over = true
      if @report.present?
       #@report.member_num,@report.member_unvalid = update_member(@campaign)
      else
       @bi_over = false
      end
    else
      @campaign = nil
    end
   
  end
 
  
  #退订用户信息
  def unsubscribe
    @unsub = Unsubscribe.select("email,created_at")
               .where("campaign_id=#{params[:c_id]}")
  end
  
  #开信、点击用户使用浏览器比例
  def browser
    
    #render :text => browsers.to_s
    
  end
  
  #开信、点击用户邮箱域名比例
  def domain
    
  end
  
  #开信、点击用户地理位置段
  def user_map
    
  end
  
  #模板链接点击数据处理
  
  
  def rank(array)
    click_num = 0
    rank_index = 1
    array.each_with_index do |item,index|
      if item[:click_num] == 0
        item.merge!({:zero => 1})
      else
        item.merge!({:zero => 0})
      end
      if index == 0
        item.merge!({:rank => rank_index})
        click_num = item[:click_num]
        rank_index += 1
      else
        if item[:click_num] == click_num
          item.merge!({:rank => array[index-1][:rank_index]})
        else
          item.merge!({:rank => rank_index})
          click_num = item[:click_num]
          rank_index += 1
        end
      end
    end
    array
  end
  
  def clickinfo
    campaign_id = params[:campaign_id]
    
    arr_clicks, @tname = perform(campaign_id)
    
    count_clicks = Array.new
    #该campaign所有点击次数
    all_num = Click.select("count(*) as count").where("campaign_id=#{campaign_id}")[0].count
    
    if arr_clicks.present?
      arr_clicks.each do |hlink|
        click_num = Click.select("count(*) as count")
                         .where("link_id=#{hlink[:l]} and campaign_id=#{hlink[:c]}")[0].count
        if all_num > 0 and click_num > 0 then
           percent = (Float(click_num)/Float(all_num)*100).round(1)
        else
           percent = 0
        end
        click_info = click_num > 0 ? "#{click_num}(#{percent}%)" : "0"
        
        count_clicks.push(
          {:link_id     => hlink[:l],
           :campaign_id => hlink[:c],
           :click_num   => click_num,
           :click_info  => click_info})
      end
      #提前排序
      count_clicks.sort!{ |x,y| y[:click_num] <=> x[:click_num] }
    end
    @rank_clicks = rank(count_clicks)

    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  
  def perform(id)
    @campaign = Campaign.find(id.to_i)
    from_name = @campaign.from_name
    from_email = @campaign.from_email
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    
    alink = nil
    fname = nil
    if @campaign.template.present?
      template_name = @campaign.template.file_name
      
      template_img_url = @campaign.template.img_url
      
      memberarray = Array.new
      @campaign.lists.collect(&:members).flatten.each do |member|
        memberarray.push(member.id)
      end
      members = Member.find(memberarray.uniq)
      if members.count > 0 then
          to_email = "hello"
          to_name = id.to_s
          alink,fname = email_with_template_job(from_email, from, to_email, to_name, members.first.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url)
      end
     else
       alink = []
       fname = ''
     end
     return [alink,fname]
  end
  
  def email_with_template_job(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url)
    readfile = YAML.load_file('config/readfile.yml')
    readip = readfile["sendip"]
    readport = readfile["sendport"]
    bodyhtml = "<body>"
    _bodyhtml,alink = display_email_job(template_id,img_url,member_id,campaign_id)
    bodyhtml << _bodyhtml
    #删掉开信记录的图片
    #bodyhtml << %Q{<img src="http://#{readip}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
    bodyhtml << "</body>"
    
    sendmail= Rails.root.join("app","views","report","templates","#{to_name}.html.erb")
    unless File.exists? sendmail
      file = File.open(sendmail,"w")
      file.print(bodyhtml.to_s)
      file.close
      puts "*"*50
      puts "write"
    else
      puts "*"*50
      puts "no write"
    end

    return [alink,File.basename(sendmail)]
  end

  def display_email_job(template_id,img_url,member_id,campaign_id)
    alink = Array.new
    readfile = YAML.load_file('config/readfile.yml')
    readip = readfile["sendip"]
    readport = readfile["sendport"]
    template = Template.find(template_id)
    if template.zip_url != nil then
      images = "/files/" + template.zip_url.to_s.split(".")[0] + "/images/"
    else
      images = "/images/"
    end
    entries = Entry.find_all_by_template_id(template_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
    puts "@"*50
    puts "#{template.file_name}.html.erb"
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
            source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{readip}:#{readport}#{images}" + e.default_value)
          end
        end
        
      else
        v = e.default_value
        if %r{^(http|https)://(.*)}.match(e.default_value)
          link = Link.where(:url => v).first_or_create
          v = "http://#{readip}:#{readport}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
          alink.push({:u=>"#{member_id}",:c=>"#{campaign_id}",:l=>"#{link.id}"})
          source = source.gsub(/\$\|#{e.name}\|\$/, v)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    end
    return [source.lstrip.to_s,alink]
  end
  
  
    require 'csv'
  #导出CSV
  def export
    
    campaign_id  = params[:c_id]
    keyword      = params[:keyword]
    file_name = "report_#{keyword}_#{Time.now.strftime("%Y%m%d%H%M%S")}"
    
    if keyword == "track" then
      xls_ws = export_track(campaign_id)
    elsif keyword == "click" then
      xls_ws = export_click(campaign_id)
    elsif keyword == "unsub" then
      xls_ws = export_unsub(campaign_id)
    end
    
    respond_to do |format|
      format.xls { send_data(xls_content_for(xls_ws,keyword),
                        :type => "text/xls;charset=utf-8; header=present",  
                        :filename => "#{file_name}.xls")
                 }
      format.csv { send_data(generate_csv(campaign_id,keyword),
                        :type => "text/csv;charset=utf-8; header=present",  
                        :filename => "#{file_name}.csv")
                 }
    end
    
  end
 
  def generate_csv(campaign_id,keyword)
    file_name = "export-"+Time.now.to_i.to_s+".csv"

    csv_ret = CSV.generate(col_sep: "\t")  do |csv|
        csv << ["a","a","a","a"]
        csv << ["链接名称","会员信息","最近点击时间","点击次数"]
    end
    return csv_ret
  end
  


  
  def xls_content_for(xls_ws,keyword)
    xls_report = StringIO.new
      
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "click details"
    
    Spreadsheet.client_encoding = "UTF-8"
    legend = Spreadsheet::Format.new :color => :black, 
                                   :weight => :bold, 
                                   :size => 11,
                                   :horizontal_align=> :center,
                                   :vertical_align => :center,
                                   :pattern_fg_color => :gray
    row_style = Spreadsheet::Format.new :size => 11,
                                   :horizontal_align=> :left,
                                   :vertical_align => :center
                                   #:rotation=> 90
    sheet1.row(0).default_format = legend


    row_index = 1
    if keyword == "click" then
      sheet1.row(0).concat %w{会员信息 链接信息 最近点击时间 点击次数}
      xls_ws.each  do |row|
       sheet1.row(row_index).default_format = row_style
       sheet1[row_index,0]= (row.member.name.strip.length>0 ? (row.member.name + "<" + row.member.email + ">") : row.member.email)
       sheet1[row_index,1]= row.link.url
       sheet1[row_index,2]= row.last_at.strftime("%Y/%m/%d %H:%M:%S")
       sheet1[row_index,3]= row.count
       row_index += 1
      end
    elsif keyword == "track" then
      sheet1.row(0).concat %w{会员信息 最近开信时间  开信次数}
      xls_ws.each  do |row|
       sheet1.row(row_index).default_format = row_style
       sheet1[row_index,0]= (row.member.name.strip.length>0 ? (row.member.name + "<" + row.member.email + ">") : row.member.email)
       sheet1[row_index,1]= row.last_at.strftime("%Y/%m/%d %H:%M:%S")
       sheet1[row_index,2]= row.count
       row_index += 1
      end
    elsif  keyword == "unsub" then
      sheet1.row(0).concat %w{会员信息 退订时间 }
      xls_ws.each  do |row|
       sheet1.row(row_index).default_format = row_style
       sheet1[row_index,0]= row.email
       sheet1[row_index,1]= row.created_at.strftime("%Y/%m/%d %H:%M:%S")
       row_index += 1
      end
    end

    book.write xls_report
    xls_report.string
  end
  
  def export_click(campaign_id)
     Click.includes(:member, :campaign, :link)
        .select("member_id,campaign_id,link_id,count(*) as count,max(updated_at) as last_at")
        .group("member_id,link_id")
        .order("max(updated_at) desc")
        .where("campaign_id=?",campaign_id)

     
  end
  
  def export_track(campaign_id)
      Track.includes(:member,:campaign)
        .select("campaign_id,member_id,count(*) as count,max(created_at) as last_at")
        .group("member_id")
        .order("max(updated_at) desc")
        .where("campaign_id = ?",campaign_id)
  end
  
  def export_unsub(campaign_id)
      Unsubscribe.select("email,created_at")
        .order("created_at desc")
        .where("campaign_id = ?",campaign_id)
  end
  
  
 def perform_job
    id=140
    user_id=current_user.id
    
    user_org_id,user_org_name = FocusMail::ListUserorg::userorg(user_id)
    
    @campaign = Campaign.find(id.to_i)
    from_name = @campaign.from_name
    puts from_name
    from_email = @campaign.from_email
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    template_name = @campaign.template.file_name
    template_img_url = @campaign.template.img_url
    
    memberarray = Array.new
    @campaign.lists.collect(&:members).flatten.each do |member|
      typeemails = [1,4,5]
      if typeemails.index(member.type_email.to_i) != nil then
        memberarray.push(member.id)
      end
    end
    members = Member.find(memberarray.uniq)
    puts "*"*50
    puts members.count
    readfile = YAML.load_file('config/readfile.yml')

    slnum = Smtplist.count(:conditions => "domain like '%163%'")
    #ips = ["210.14.76.206","210.14.76.208","3524152526","3524152528","m3.intfocus.com","m4.intfocus.com","m7.intfocus.com","m8.intfocus.com"]
    ips = readfile["ips"].to_s.split(",")
    strdomain = ["intfocus.com","stnc.cn","online-edm.com"]
    slid = 0
    ipid = 0
    domainid = 0
    slen = ""
    slpwd = ""
    ipstr = ""
    domainstr = ""

    #生成位置 - base_dir/org_name/campaign_id/+email_domain+
    #此处为共用地址 base_dir/org_name/campaign_id
    filepath = readfile["sendmail"].to_s
    filepath = File.join(filepath,user_org_name,id.to_s)
    puts filepath
            
    for i in 0...1 do
      if members.count > 0 then
        if members.count == 1 then
          puts "*"*50
          puts "only one"
          to_email = members[0].email          
          #检测邮箱地址,符合基本格式email_name@email_domain
          if to_email.split("@").length == 2  
            to_email_downcase = to_email.split("@")[1].downcase
            puts to_email_downcase
            
            #重用查找对应邮箱域名的文件夹名的代码
            domain_str = find_toemailname(to_email_downcase)
            puts domain_str
            
            #生成位置 - base_dir/org_name/campaign_id/email_domain
            #生成信文本信息在FocusMail::TemplateEmail中操作
            filepath = File.join(filepath,domain_str)
            puts filepath
            
            FileUtils.mkdir_p(filepath) unless File.exist?(filepath)
            to_name = members[0].name
            sl = Smtplist.offset(slid).limit(1).first
            begin
              email_smtp = sl.email_smtp
              email_port = sl.email_port.to_i
              email_domain = sl.domain
              login_name = sl.login_name
              email_name = sl.email_name
              email_pwd = sl.email_pwd
              domainstr = strdomain[1]
              ipstr = ips[0]
              
              #使用nohup运行resque，puts会写在nohup.out
              puts "00-to_emai-"+to_email.to_s+"-"+ipstr.to_s
                
              FocusMail::TemplateEmail.email_with_template_job(from_email, from, to_email, to_name, members[0].id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,user_id,email_smtp,email_port,email_domain,login_name,email_pwd,email_name,ipstr,domainstr,filepath)
            rescue => e
              if sl == nil then
                @error = "error"
                puts "sl is empty"
              else
                puts e.inspect
              end
            end
          end
        else
          members.each_with_index do |m,index|
            to_email = m.email
            #检测邮箱地址,符合基本格式email_name@email_domain
            if to_email.split("@").length == 2  
              to_email_downcase = to_email.split("@")[1].downcase
              puts to_email_downcase
              
              #重用查找对应邮箱域名的文件夹名的代码
              domain_str = find_toemailname(to_email_downcase)
              puts domain_str
              
              #生成位置 - base_dir/org_name/campaign_id/email_domain
              #生成信文本信息在FocusMail::TemplateEmail中操作
              filepath = File.join(filepath,domain_str)
              puts filepath
              FileUtils.mkdir_p(filepath) unless File.exist?(filepath)
              to_name = m.name
              if slid < slnum then
                sl = Smtplist.where(["domain like :d", {:d => "%163%"} ]).offset(slid).limit(1).first
                slid += 1
              else
                slid = 0
                sl = Smtplist.where(["domain like :d", {:d => "%163%"} ]).offset(slid).limit(1).first
                slid += 1
              end
              if ipid < ips.count then
                ipstr = ips[ipid]
                ipid += 1
              else
                ipid = 0
                ipstr = ips[ipid]
                ipid += 1
              end
              if domainid < strdomain.count then
                domainstr = strdomain[domainid]
                domainid += 1
              else
                domainid = 0
                domainstr = strdomain[domainid]
                domainid += 1
              end
                email_smtp   =   sl.email_smtp
                email_port   =   sl.email_port.to_i
                email_domain =   sl.domain
                login_name   =   sl.login_name
                email_name   =   sl.email_name
                email_pwd    =   sl.email_pwd
                
                #使用nohup运行resque，puts会写在nohup.out
                puts "#{index}-to_emai-"+to_email+"-"+ipstr
                            
                FocusMail::TemplateEmail.email_with_template_job(from_email, from, to_email, to_name, m.id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,user_id,email_smtp,email_port,email_domain,login_name,email_pwd,email_name,ipstr,domainstr,filepath)
            end
          end
          
        end
      end
    end
    render :text => "perform over"
  end
  
  def find_toemailname(to_email_downcase)
      toemailname = "other"
      if to_email_downcase.index("sina") != nil then
        toemailname = "sina"
      end
      if to_email_downcase.index("qq") != nil then
        toemailname = "qq"
      end
      if to_email_downcase.index("yahoo") != nil then
        toemailname = "yahoo"
      end
      if to_email_downcase.index("gmail") != nil then
        toemailname = "gmail"
      end
      if to_email_downcase.index("sohu") != nil then
        toemailname = "sohu"
      end
      if to_email_downcase.index("tom") != nil then
        toemailname = "tom"
      end
      if to_email_downcase.index("163") != nil then
        toemailname = "163"
      end
      if to_email_downcase.index("126") != nil then
        toemailname = "163"
      end
      if to_email_downcase.index("yeah") != nil then
        toemailname = "163"
      end
      if to_email_downcase.index("foxmail") != nil then
        toemailname = "qq"
      end
      if to_email_downcase.index("hotmail") != nil then
        toemailname = "hotmail"
      end
      return toemailname
  end
end
