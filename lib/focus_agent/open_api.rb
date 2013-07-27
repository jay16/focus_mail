module FocusAgent
  class OpenApi
    def self.perform(name,email,href)
      @campaign        = Campaign.find(id.to_i)
      from_name        = @campaign.from_name
      from_email       = @campaign.from_email
      from             = from_name.present? ? %{"#{from_name}" <#{from_email}>} : from_email
      subjects         = @campaign.subject.split("|$$|")
      subject_num      = subjects.length
      template_name    = @campaign.template.file_name
      template_img_url = @campaign.template.img_url
  
      readfile  = YAML.load_file('config/readfile.yml')
  
      slnum     = Smtplist.count(:conditions => "domain like '%163%'")
      ips       = readfile["ips"].to_s.split(",")
      strdomain = ["stnc.cn","online-edm.com"]
      
      slid, ipid, domainid, slen, slpwd, ipstr, domainstr = 0, 0, 0, "", "", "", ""
      
      #生成位置 - base_dir/org_name/campaign_id/+email_domain+
      #此处为共用地址 base_dir/org_name/campaign_id
      innertest_id = "#{id}_InnerTest"
      basepath = readfile["sendmail"].to_s
      mailpath = File.join(basepath,"openapi")

      subject  = subjects[0]
      to_email = email
      to_name  = name
              
      slid     = rand(slnum)
      ipid     = rand(ips.count)
      domainid = rand(strdomain.count)
      sl       = Smtplist.where(["domain like :d", {:d => "%163%"} ]).offset(slid).limit(1).first
  
  
      options  = {
	:from_email => from_email,
	:from       => from,
	:to_email   => to_email,
	:to_name    => to_name
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
