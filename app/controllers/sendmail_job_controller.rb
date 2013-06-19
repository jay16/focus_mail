#encoding : utf-8
class SendmailJobController < ApplicationController

 def perform
    id=140
    user_id=current_user.id
    
    user_org_id,user_org_name = FocusMail::ListUserorg::userorg(user_id)
    @campaign = Campaign.find(id.to_i)
    from_name = @campaign.from_name
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

    for i in 0...1 do
      if members.count > 0 then
        if members.count == 1 then
          to_email = members[0].email          
          #检测邮箱地址
          if to_email.split("@").length == 2  
            to_email_downcase = to_email.split("@")[1].downcase
            
            #重用查找对应邮箱域名的文件夹名的代码
            filename = find_toemailname(to_email_downcase)
            
            filepath = readfile["sendmail"].to_s + filename
            FileUtils.mkdir(filepath) unless File.exist?(filepath)
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
              puts "#{index}-to_emai-"+to_email+"-"+ipstr
                
              FocusMail::TemplateEmail.email_with_template_job(from_email, from, to_email, to_name, members[0].id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,user_id,email_smtp,email_port,email_domain,login_name,email_pwd,email_name,ipstr,domainstr,filepath)
            rescue
              if sl == nil then
                @error = "error"
              end
            end
          end
        else
          members.each_with_index do |m,index|
            to_email = m.email

            #检测邮箱地址
            if to_email.split("@").length == 2  
              to_email_downcase = to_email.split("@")[1].downcase
                          
              #重用查找对应邮箱域名的文件夹名的代码
              filename = find_toemailname(to_email_downcase)
              
              readfile = YAML.load_file('config/readfile.yml')
              filepath = File.join(readfile["sendmail"].to_s,user_org_name,id,filename)
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