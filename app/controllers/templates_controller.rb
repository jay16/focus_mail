#encoding : utf-8
require 'will_paginate/array'
class TemplatesController < ApplicationController

  def index
    #@templates = Template.all
    #@template = Template.new
    user_id = current_user.id
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @templates = Template.paginate(:page => params[:page], :per_page => 10,:order => "updated_at desc")
    else
      controller = "Template"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      if orglist.empty?
        @templates = nil
      else
        @templates = Template.paginate(:page => params[:page], :per_page => 10, :conditions => "id in (#{orglist.join(',')})" , :order => "updated_at desc")
      end
    end
    @template = Template.new
    @template.fname = "#{current_user.id}-#{Time.now().to_i}"
    @template.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    user_action_log(0,params[:controller],"index")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @templates }
    end
  end

  def show
    @template = Template.find(params[:id])
    user_action_log(params[:id],params[:controller],"show")
    respond_to do |format|
      format.html { redirect_to :action => "index" } # show.html.erb
      format.json { render json: @template }
    end
  end

  def new
    #@template = Template.new
    user_id = current_user.id
    @template = Template.new
    @template.fname = "#{current_user.id}-#{Time.now().to_i}"
    @template.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @template = Template.find(params[:id])
    user_action_log(params[:id],params[:controller],"edit")

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    puts "*"*100
    puts "templtea create"
    if_succ = false
    path = ""
     #如果什么也没有接收到
    if request.get?
      @system_uploadfile = SystemUploadfile.new
      flash.now[:notice] = "文件上传失败"
      render :action => "new"
    else
      @template = Template.new(params[:template])
      @template.user_email = current_user.email
      @template.file_name = @template.fname #"#{current_user.id}-#{Time.now().to_i}"
      #获取上传的文件
      uploaded_file = params[:template][:zip_url]
      if uploaded_file != "" && uploaded_file != nil then
        if_succ,filepath,path = upload_file(uploaded_file,Template::File_extname,Template::File_target)
      end
  
      respond_to do |format|
        if if_succ then
          @template.set_file_values(filepath, uploaded_file.original_filename)
          puts "upload file success!"
          #修改上传文件的权限
          #system 'chown -R webmail:webmail /home/work/focus_mail/public/files'
        end
        if @template.save
          user_action_log(@template.id,params[:controller],"create")
          format.html { redirect_to @template, notice: 'Template was successfully created.' }
          format.js
        else
          format.html { render action: "new" }
          format.js { render action: "new" }
        end
      end
    end
  end

  def update
    @template = Template.find(params[:id])
    @template.user_email = current_user.email

    respond_to do |format|
      if @template.update_attributes(params[:template])
        user_action_log(params[:id],params[:controller],"update")
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @template = Template.find(params[:id])
    @template.destroy
    user_action_log(params[:id],params[:controller],"delete")

    respond_to do |format|
      format.html { redirect_to templates_url }
      format.js
    end
  end
  
  def saveimgurl
    imgurl = params[:iu]
    if imgurl != "" && imgurl != nil then
      imgurls = imgurl.split("_")
      puts imgurls[0]
      puts imgurls[1]
      Template.update(imgurls[0], :img_url => imgurls[1])
    end
  end
  
  def upload_file(file,extname,target_dir)
    if file.nil? || file.original_filename.empty?
      return false,"空文件或者文件名错误"
    else
      timenow = Time.now
      filename = file.original_filename  #file的名字
      mvfilename = (0..16).to_a.map{|a| rand(16).to_s(16)}.join #产生一个十六进制的字符串
      fileloadname = timenow.strftime("%d%H%M%S")+mvfilename+".zip" #保存在文件夹下面的上传文件的名称

      if extname.include?(File.extname(filename).downcase)
        #创建目录
        #首先获得当前项目所在的目录+文件夹所在的目录
        path = Rails.root.join(target_dir,timenow.year.to_s,timenow.month.to_s)
        #生成目录
        FileUtils.makedirs(path)
        File.open(File.join(path,fileloadname),"wb") do |f|
          f.write(file.read)
          return true,File.join(timenow.year.to_s,timenow.month.to_s,fileloadname),path
        end
      else
        return false,"必须是#{extname}类型的文件"
      end
    end
  end
  def grade
    grade = Template.find(params[:template_id]).grade
    if grade == nil then
      grade = 0.0
    end     
    @templates_grade = case
    when grade < 0.1
      "正常信"
    when (0.1 <= grade and grade <= 0.9)
      "可疑信"
    when (0.9 <= grade and grade <= 1.0)
      "符合贝氏资料库"
    when grade == 1.01
      "URL符合URLBW"
    when grade == 1.02
      "符合线上专用的milo_dycheckB.so或milo_dycheck.so"
    when grade == 1.03
      "URL包含不合法字元"
    when grade == 1.04
      "URL为转址网址且转址次数大于等于2"
    when grade == 1.05
      "URL符合URIBL"
    when grade == 1.06
      "符合rules。com的规则"
    when grade == 1.07
      "发信IP符合RBL"
    when grade == 1.08
      "URL符合URIBL的Phishing网址"
    when grade == 1.09
      "URL的对应IP符合URIBW"
    when grade == 1.11
      "发信IP符合URIBW"
    when grade == 1.12
      "符合SPAM Rules Center"
    when grade == 1.13
      "信件格式不符合RFC规定"
    else
      "未判断到"
    end
    @grade = case
    when grade < 0.1
      tmp = (grade*1000000).to_i.to_s[0..1].to_i
      100-tmp if tmp < 50
    else
      0
    end
  end
  
  #模板 预览
  def preview
    @template = Template.find(params[:template_id])
    
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  #模板zip上传范例下载
  def download
   file_path = Rails.root.join("public","template-demo.zip")
   if File.exist?(file_path)
     io = File.open(file_path)
     io.binmode
     send_data(io.read,:filename => "zip上传范例.zip",:disposition => 'attachment')
     io.close
   end   
  end
end
