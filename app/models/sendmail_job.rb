#encoding:utf-8
require 'resque'
require 'mail'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'

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
    ips = readfile["ips"].to_s.split(",")
    strdomain = ["intfocus.com","stnc.cn","online-edm.com"]
    
    slid      = 0
    ipid      = 0
    domainid  = 0
    slen      = ""
    slpwd     = ""
    ipstr     = ""
    domainstr = ""
    
    #生成位置 - base_dir/org_name/campaign_id/+email_domain+
    #此处为共用地址 base_dir/org_name/campaign_id
    basepath = readfile["sendmail"].to_s
    basepath = File.join(basepath,user_org_name,id.to_s)
    
    for i in 0...1 do
      if members.count > 0 then
        if members.count == 1 then
          to_email = members[0].email
          subject  = subjects[0]    
          #检测邮箱地址
          if to_email.split("@").length == 2  
            
            to_email_downcase = to_email.split("@")[1].downcase
            #重用查找对应邮箱域名的文件夹名的代码
            domain_str = find_toemailname(to_email_downcase)
            #生成位置 - base_dir/org_name/campaign_id/email_domain
            #生成信文本信息在FocusMail::TemplateEmail中操作
            filepath   = File.join(basepath,domain_str)
            
            to_name    = members[0].name
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
                
              FocusMail::TemplateEmail.email_with_template_job(from_email, from, to_email, to_name, members[0].id, subject, @campaign.id, @campaign.template.id, @campaign.template.img_url,user_id,email_smtp,email_port,email_domain,login_name,email_pwd,email_name,ipstr,domainstr,filepath)
            rescue
              if sl == nil then
                @error = "error"
              end
            end
          end
        else
          members.each_with_index do |m,index|
            subject  = subjects[index%subject_num]
            to_email = m.email
            #检测邮箱地址
            if to_email.split("@").length == 2  
              to_email_downcase = to_email.split("@")[1].downcase

              #重用查找对应邮箱域名的文件夹名的代码
              domain_str = find_toemailname(to_email_downcase)
  
              #生成位置 - base_dir/org_name/campaign_id/email_domain
              #生成信文本信息在FocusMail::TemplateEmail中操作
              filepath = File.join(basepath,domain_str)
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
#  def email_with_template_job(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url,user_id,email_smtp,email_port,email_domain,login_name,email_pwd,email_name,ipstr,domainstr,filepath)
#    readfile = YAML.load_file('config/readfile.yml')
#    readip = readfile["sendip"]
#    readport = readfile["sendport"]
#    bodyhtml = "<body>"
#    bodyhtml << Sendmail_Job.new.display_email_job(template_id,img_url,member_id,campaign_id,to_name,ipstr)
#    bodyhtml << %Q{<img src="http://#{ipstr}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
#    #bodyhtml << "<div style='display:none'>#{Kxword.find(rand(28331)+1).content.strip}</div>"
#    #bodyhtml << "<div style='display:none'>#{Kxword.find(rand(28331)+1).content.strip}</div>"
#    bodyhtml << "</body>"
#    mail = Mail.new do
#      to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email
#      from    from
#      message_id '<' + Time.now().to_f.to_s + '@' + Time.now().to_f.to_s.split(".")[1] + '.com>'
#      subject subject
#
#      html_part do
#        content_type 'text/html; charset=UTF-8'
#        content_id '<' + Time.now().to_f.to_s + '@' + Time.now().to_f.to_s.split(".")[1] + '.com>'
#        content_transfer_encoding 'base64'
#        body Base64.encode64(bodyhtml)
#      end
#    end
#    filename = member_id.to_s + "_" + Time.now().to_f.to_s
#    sendmail = filepath + "/#{filename}.eml"
#    file = File.open(sendmail,"w")
#    hfrom = to_email.to_s.split("@")[0] + "_#{campaign_id}_0@" + domainstr.to_s
#    strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + hfrom + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
#    #strfile = Time.now().to_i.to_s + " 00" + " A\"#{email_smtp}:#{email_port.to_s}\":#{email_name.index('@') > 0 ? "\"#{email_name}\"" : email_name}:\"#{email_pwd}\" \r\n" + "F" + email_name + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
#    strfile << mail.to_s
#    file.print(strfile.gsub!(/\r\n/, "\n"))
#    file.close
#    Sendmail_Job.new.create_email_log(template_id,hfrom,to_email,subject,user_id,campaign_id)
#  end
#  
#  def display_email_job(template_id,img_url,member_id,campaign_id,to_name,ipstr)
#    readfile = YAML.load_file('config/readfile.yml')
#    readip = readfile["sendip"]
#    readport = readfile["sendport"]
#    template = Template.find(template_id)
#    if template.zip_url != nil then
#      images = "/files/" + template.zip_url.to_s.split(".")[0] + "/images/"
#    else
#      images = "/images/"
#    end
#    entries = Entry.find_all_by_template_id(template_id)
#    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
#    source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
#    source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
#    source = source.gsub(/\$\|NAME\|\$/, to_name)
#    entries.each do |e|
#      if e.name.include? "img" then
#        if img_url == 1 then
#          source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
#        else
#          if(e.default_value.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
#            source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
#          else
#            source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{readip}:#{readport}#{images}" + e.default_value)
#            #source = source.gsub(/\$\|#{e.name}\|\$/, "#{images}" + e.default_value)
#          end
#        end
#        
#      else
#        v = e.default_value
#        if %r{^(http|https)://(.*)}.match(e.default_value)
#          link = Link.where(:url => v).first_or_create
#          v = "http://#{ipstr}:#{readport}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
#          source = source.gsub(/\$\|#{e.name}\|\$/, v)
#        else
#          source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
#        end
#      end
#    end
#    return source.lstrip.to_s
#  end
#  
#  def create_email_log(template_id,hfrom,to_email,subject,user_id,campaign_id)
#    CemailLog.create({
#      :campaign_id => campaign_id,
#      :template_id => template_id,
#      :from_email => hfrom,
#      :to_eamil => to_email,
#      :subject => subject,
#      :user_id => user_id
#    })
#  end
end
