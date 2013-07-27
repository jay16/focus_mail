#encoding:utf-8
require 'resque'
require 'mail'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'
require 'fileutils'
require "open-uri" 

class Sendmail_Job
  @queue = "job_mail_producer"
  def self.perform(id,user_id)
    user_org_id,user_org_name = FocusMail::ListUserorg::userorg(user_id)
    @campaign        = Campaign.find(id.to_i)
    from_name        = @campaign.from_name
    from_email       = @campaign.from_email
    from             = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
    subjects         = @campaign.subject.split("|$$|")
    subject_num      = subjects.length
    template_name    = @campaign.template.file_name
    template_img_url = @campaign.template.img_url

    focus_server = FocusServer.create({:campaign_id => id,
      :send_type => "send",
      :stage     => 1})
   
    memberarray = Array.new
    all_members = @campaign.lists.collect(&:members).flatten
    
    focus_server.campaign_records.create({:i => 1,
      :stage     => 1,
      :info_json => {"all_members_num" => all_members.size}.to_s
      })
    
    all_members.each do |member|
      typeemails = [1,4,5]
      if typeemails.index(member.type_email.to_i) != nil then
        memberarray.push(member.id)
      end
    end
    
    uniq_members = memberarray.uniq
    
    focus_server.campaign_records.create({:i => 2,
      :stage     => 1,
      :info_json => {"145" => memberarray.size,"uniq" => uniq_members.size}.to_s
      })
    focus_server.update_attributes({
      :stage => 1,
      :info  => {"all" => all_members.size, "145" => memberarray.size, "uniq" => uniq_members.size }.to_s 
      })
    
    members = Member.find(uniq_members)

    readfile  = YAML.load_file('config/readfile.yml')

    slnum     = Smtplist.count(:conditions => "domain like '%163%'")
    ips       = readfile["ips"].to_s.split(",")
    strdomain = ["intfocus.com","stnc.cn","online-edm.com"]
    
    slid, ipid, domainid, slen, slpwd, ipstr, domainstr = 0, 0, 0, "", "", "", ""
    
    #生成位置 - base_dir/org_name/campaign_id_邮件数量_时间戳/+email_domain+
    #此处为共用地址 base_dir/org_name/campaign_id
    basepath = readfile["sendmail"].to_s
    #tarpath basepath先后顺序不可错乱
    orgpath  = File.join(basepath,user_org_name)
    camname  = "#{id}_#{members.size}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
    campath = File.join(basepath,user_org_name,camname)

    focus_server.update_attributes({
      :file_name => camname,
      :info  => {"all" => all_members.size, "145" => memberarray.size, "uniq" => uniq_members.size, "filename" => camname }.to_s 
      })
    
    focus_server.campaign_records.create({:i => 3,
      :stage     => 1,
      :info_json => {"campaign_name" => camname, "campath" => campath}.to_s
      })

    for i in 0...1 do
      if members.count > 0 then
         members.each_with_index do |m,index|
            #轮流使用多主题
            subject  = subjects[index%subject_num]
            to_email = m.email
            #检测邮箱地址
            next if to_email.split("@").length != 2  
            to_email_downcase = to_email.split("@")[1].downcase
    
            #重用查找对应邮箱域名的文件夹名的代码
            domain_str = find_toemailname(to_email_downcase)
    
            #生成位置 - base_dir/org_name/campaign_id_邮件数量_时间戳/+email_domain+
            #生成信文本信息在FocusMail::TemplateEmail中操作
            filepath = File.join(campath,domain_str)
            FileUtils.mkdir_p(filepath) unless File.exist?(filepath)
            
            slid     = Integer(rand(slnum))
            ipid     = Integer(rand(ips.count))
            domainid = Integer(rand(strdomain.count))
            sl       = Smtplist.where(["domain like :d", {:d => "%163%"} ]).offset(slid).limit(1).first


            options  = {
              :from_email => from_email,
              :from       => from,
              :to_email   => to_email,
              :to_name    => m.name,              #to_name,
              :member_id  => m.id,
              :subject    => subject,
              :campaign_id  => @campaign.id,
              :template_id  => @campaign.template.id,
              :img_url      => @campaign.template.img_url,
              :user_id      => user_id,
              :email_smtp   => sl.email_smtp,      #email_smtp,
              :email_port   => sl.email_port.to_i, #email_port,
              :email_domain => sl.domain,          #email_domain,
              :login_name   => sl.login_name,      #login_name,
              :email_pwd    => sl.email_pwd,       #email_pwd,
              :email_name   => sl.email_name,      #email_name,
              :ipstr        => ips[ipid],          #ipstr,
              :domainstr    => strdomain[domainid],#domainstr,
              :filepath     => filepath
            }          
            
            FocusMail::TemplateEmail.email_with_template_job(options)
         end
      end
    end
    
    #生成信完毕,直接在本文件夹内压缩
    system("cd #{orgpath} && tar -czvf #{camname}.tar.gz #{camname}")

    tar_path = "#{orgpath}/#{camname}.tar.gz"
    focus_tar = readfile["focus_tar"].to_s
    if File.exist?(tar_path) then
        FocusAgent::Avoid.conflict("#{focus_tar}/#{id}.tar.gz")
        FileUtils.mv(tar_path,focus_tar)
    else
        puts "ERROR:NOT EXIST - #{tar_path}"
    end
    
  end 
  
  def self.find_toemailname(to_email_downcase)
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
