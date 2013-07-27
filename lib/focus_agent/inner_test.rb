module FocusAgent
  class InnerTest
    def self.perform(test_emails,id,user_id,is_smtp)
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
      test_emails.each do |email|
        puts "*"*100
        puts email
        email.chomp!
        next if email.split(/@/).length != 2
        tm = Member.where(:email => email).first_or_create(:name => email)
        puts tm.id
        memberarray.push(tm.id)
      end
      
      members = Member.find(memberarray.uniq)
      puts "*"*50
      puts members.count
      readfile  = YAML.load_file('config/readfile.yml')
  
      slnum     = Smtplist.count(:conditions => "domain like '%163%'")
      ips       = readfile["ips"].to_s.split(",")
      strdomain = ["stnc.cn","online-edm.com"]
      
      slid, ipid, domainid, slen, slpwd, ipstr, domainstr = 0, 0, 0, "", "", "", ""
      
      #生成位置 - base_dir/org_name/campaign_id/+email_domain+
      #此处为共用地址 base_dir/org_name/campaign_id
      innertest_id = "#{id}_InnerTest"
      basepath = readfile["sendmail"].to_s
      orgpath  = File.join(basepath,user_org_name)
      campath = File.join(basepath,user_org_name,innertest_id)
      #若basepath文件夹已经存在，修改文件夹名称，避免eml文件冲突
      FocusAgent::Avoid.conflict(campath)
      
      for i in 0...1 do
        if members.count > 0 then
           members.each_with_index do |m,index|
              subject  = subjects[index%subject_num]
              to_email = m.email
              #检测邮箱地址
              next if to_email.split("@").length != 2  
              to_email_downcase = to_email.split("@")[1].downcase
      
              #重用查找对应邮箱域名的文件夹名的代码
              domain_str = find_toemailname(to_email_downcase)
      
              #生成位置 - base_dir/org_name/campaign_id/email_domain
              #生成信文本信息在FocusMail::TemplateEmail中操作
              filepath = File.join(campath,domain_str)
              FileUtils.mkdir_p(filepath) unless File.exist?(filepath)
              
              slid     = rand(slnum)
              ipid     = rand(ips.count)
              domainid = rand(strdomain.count)
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
                :filepath     => filepath,
                :is_smtp      => is_smtp
              }          
              
              FocusMail::TemplateEmail.email_with_template_job(options)
           end
        end
      end
      
      #生成信完毕,直接在本文件夹内压缩
      system("cd #{orgpath} && tar -czvf #{innertest_id}.tar.gz #{innertest_id}")
  
      tar_path = "#{orgpath}/#{innertest_id}.tar.gz"
      focus_tar = "/home/webmail/focus_tar"
      if File.exist?(tar_path) then
          FocusAgent::Avoid.conflict("#{focus_tar}/#{innertest_id}.tar.gz")
          FileUtils.mv(tar_path,focus_tar)
          mail_type = 0
          FocusAgent::Trigger.fork("#{focus_tar}/#{innertest_id}.tar.gz",id,mail_type)
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
end