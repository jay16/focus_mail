#encoding : utf-8
require 'resque'
require 'mail'

class CampaignsController < ApplicationController
  # GET /campaigns
  # GET /campaigns.json
  
  def index
    require 'will_paginate/array'
    #@campaigns = Campaign.all
    #@campaign = Campaign.new
    user_id = current_user.id
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @campaigns = Campaign.paginate(:page => params[:page], :per_page => 6,:order => "updated_at desc")
      @campaign = Campaign.new
      @lists = List.where("is_used != false")
      @templates = Template.all
    else
      controller = "Campaign"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      if orglist.empty?
        @campaigns = nil
      else
        #@campaigns = Campaign.find(orglist).paginate(:page => params[:page], :per_page => 6,:order => "updated_at desc")
        @campaigns = Campaign.paginate(:page => params[:page], :per_page => 6, :conditions => "id in (#{orglist.join(',')})" , :order => "updated_at desc")
      end
      @campaign = Campaign.new
      @campaign.org_id = FocusMail::ListUserorg::userorg_id(user_id)
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @templates = Template.find(orglist)
    
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).select{ |l| l.is_used != false }
    end
      
    user_action_log(0,params[:controller],"index")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @campaigns }
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    @campaign = Campaign.find(params[:id])
    user_action_log(params[:id],params[:controller],"show")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @campaign }
    end
  end

  def new
    user_id = current_user.id
    @campaign = Campaign.new
    @campaign.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @lists = List.where("is_used != false")
      @templates = Template.all
    else
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @templates = Template.find(orglist)
    
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).select{ |l| l.is_used != false }
    end
    @campaign.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end
  
  def copies
    user_id = current_user.id
    campaign = Campaign.find(params[:id])
    @campaign = Campaign.new
    @campaign.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    @campaign.name = campaign.name
    @campaign.from_name = campaign.from_name
    @campaign.subject = campaign.subject
    @campaign.from_email = campaign.from_email
    @campaign.template_id = campaign.template_id
    @campaign.lists = campaign.lists
    #模板、列表的选择根据权限显示
    if user_action_org then
      @lists = List.where("is_used != false")
      @templates = Template.all
    else
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @templates = Template.find(orglist)
    
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).select{ |l| l.is_used != false }
    end
    #@campaign.save
    user_action_log(0,params[:controller],"copy")
    
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end
  
  def edit
    user_id = current_user.id
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @campaign = Campaign.find(params[:id])
      @lists = List.where("is_used != false")
      @templates = Template.all
    else
      @campaign = Campaign.find(params[:id])
      @campaign.org_id = FocusMail::ListUserorg::userorg_id(user_id)
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @templates = Template.find(orglist)
    
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).select{ |l| l.is_used != false }
    end
    user_action_log(params[:id],params[:controller],"edit")
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    
    if params[:campaign][:from_time] != "" then
      strdate = params[:datepicker].to_s
      strhour = params[:selecthour].to_i
      strminute = params[:selectminute].to_i
      strsecond = params[:selectsecond].to_i
      if strdate != nil && strdate != "" then
        datearray = strdate.split("-")
        stryear = datearray[0].to_i
        strmonth = datearray[1].to_i
        strday = datearray[2].to_i
        strdatetime = Time.new(stryear,strmonth,strday,strhour,strminute,strsecond, "+08:00")
        strnow = Time.now
        strdatetime = Time.at(strnow.to_i+60) if strnow >= strdatetime

        Resque.enqueue_at(strdatetime, Sendmail_Job, params[:id], current_user.id)
      end
    end

    user_id = current_user.id
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @lists = List.where("is_used != false")
      @templates = Template.all
    else
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @templates = Template.find(orglist)
    
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).select{ |l| l.is_used != false }
    end

    respond_to do |format|
      if @campaign.save
        #新创建campaign，要对应插入dog_data一笔，可使用更新发信log数据
        unless DogData.find_by_campaign_id(@campaign.id) then 
            DogData.create({:campaign_id => @campaign.id}).save
        end
        user_action_log(@campaign.id,params[:controller],"create")
        format.html { redirect_to @campaign, notice: 'Campaign was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.js { render action: "new" }
      end
    end
  end

  def update
    @campaign = Campaign.find(params[:id])
    if params[:campaign][:from_time] != "" then
      if @campaign.from_time != nil && @campaign.from_time != "" then
        Resque.remove_delayed(Sendmail_Job, params[:id], current_user.id)
      end
      strdate = params[:datepicker].to_s
      strhour = params[:selecthour].to_i
      strminute = params[:selectminute].to_i
      strsecond = params[:selectsecond].to_i
      if strdate != nil && strdate != "" then
        datearray = strdate.split("-")
        stryear = datearray[0].to_i
        strmonth = datearray[1].to_i
        strday = datearray[2].to_i
        strdatetime = Time.new(stryear,strmonth,strday,strhour,strminute,strsecond, "+08:00")
        strnow = Time.now
        strdatetime = Time.at(strnow.to_i+60) if strnow >= strdatetime
        Resque.enqueue_at(strdatetime, Sendmail_Job, params[:id], current_user.id)
      end
    else
      if @campaign.from_time != nil && @campaign.from_time != "" then
        Resque.remove_delayed(Sendmail_Job, params[:id], current_user.id)
      end
    end

    user_id = current_user.id
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @lists = List.where("is_used != false")
      @templates = Template.all
    else
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @templates = Template.find(orglist)
    
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).select{ |l| l.is_used != false }
    end

    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        user_action_log(params[:id],params[:controller],"update")
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy
    user_action_log(params[:id],params[:controller],"delete")

    respond_to do |format|
      format.html { redirect_to campaigns_url }
      format.js
    end
  end
  
  def mailtest
    @campaign = Campaign.find(params[:id])
    from_name = @campaign.from_name
    from_email = @campaign.from_email
    from = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subject = @campaign.subject
    template_name = @campaign.template.file_name
    to_email = params[:emailname]
    to_name = ""
    template_img_url = @campaign.template.img_url
    #生成信在email_one_template中设置
    email_one_template(from_email, from, to_email, to_name, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,current_user.id)
    user_action_log(params[:id],params[:controller],"mailtest")
  
 end

  def deliver
    Resque.enqueue(Sendmail_Job, params[:id], current_user.id)
    user_action_log(params[:id],params[:controller],"deliver")
  end

  def template_entries
    @template = Template.find(params[:t_id])
    # because sometime @campaign does not exist when it's a new one
    @campaign = Campaign.find_by_id(params[:c_id])
    user_action_log(params[:c_id],params[:controller],"template_entries")
    respond_to do |format|
      format.js
    end
  end
  
  def email_one_template(hfrom, from, to_email, to_name, subject, campaign_id, template_id, img_url,user_id)
    puts "+++++++++++++++++++++++++++++++"
    puts to_email.present?
    puts "+++++++++++++++++++++++++++++++"
    readfile = YAML.load_file('config/readfile.yml')
    bodyhtml = "<body>"
      bodyhtml << display_one_email(template_id,img_url,campaign_id)
      bodyhtml << "</body>"
      
      mail = Mail.new do
        to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email #'yy_lfy@126.com'
        from    from #'eric yue <eric_yue@intfocus.com>'
        reply_to readfile["reply"].to_s
        subject subject #'First multipart email sent with Mail大口大口的'
      
        #text_part do
         # body 'This is plain text'
        #end
      
        html_part do
          content_type 'text/html; charset=UTF-8'
          body bodyhtml.to_s
        end
        #add_file '/home/work/vicm.png'
      end
      #mail.attachments['vicm.png'] = {:mime_type => 'application/x-gzip',:content_id => abc,:content => File.read('/home/work/vicm.png')}
      #puts mail.to_s
      filename = to_name + Time.now().to_i.to_s
      #把信生成邮箱域名对应文件夹下
      to_email_downcase = to_email.split("@")[1].downcase
      toemailname = find_toemailname(to_email_downcase)
      filepath = readfile["sendmail"].to_s + toemailname
      FileUtils.mkdir(filepath) unless File.exist?(filepath)
      
      sendmail = filepath + "/#{filename}.eml"
      file = File.open(sendmail,"w")
      strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + hfrom + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
      strfile << mail.to_s
      file.print(strfile.gsub!(/\r\n/, "\n"))
      file.close

      create_email_log(template_id,hfrom,to_email,subject,user_id)
  end
  
  def display_one_email(template_id,img_url,campaign_id)
    template = Template.find(template_id)
    if template.zip_url != nil then
      images = "/files/" + template.zip_url.to_s.split(".")[0] + "/images/"
    else
      images = "/images/"
    end
    entries = Entry.find_all_by_template_id(template_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
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
        v = e.default_value
        if %r{^(http|https)://(.*)}.match(e.default_value)
          link = Link.where(:url => v).first_or_create
          v = link.url
          source = source.gsub(/\$\|#{e.name}\|\$/, v)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
        end
      end
    end
    return source.lstrip
  end
  
  def create_email_log(template_id,hfrom,to_email,subject,user_id)
    CemailLog.create({
      :template_id => template_id,
      :from_email => hfrom,
      :to_eamil => to_email,
      :subject => subject,
      :user_id => user_id
    })
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
