require 'mail'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'

module FocusApi
  module TemplateEmail
    def self.email_with_template_job(options)
      hfrom        = options[:hfrom]
      from         = options[:from]
      to_email     = options[:to_email]
      to_name      = options[:to_name] 
      href         = options[:href]
      member_id    = options[:member_id] 
      subject      = options[:subject] 
      campaign_id  = options[:campaign_id]
      template_id  = options[:template_id] 
      img_url      = options[:img_url]
      user_id      = options[:user_id]
      email_smtp   = options[:email_smtp] 
      email_port   = options[:email_port]
      email_domain = options[:email_domain] 
      login_name   = options[:login_name]
      email_pwd    = options[:email_pwd]
      email_name   = options[:email_name]
      ipstr        = options[:ipstr]
      domainstr    = options[:domainstr]
      filepath     = options[:filepath]
      
      readfile = YAML.load_file('config/readfile.yml')
      readip = readfile["sendip"]
      readport = readfile["sendport"]
      bodyhtml = "<body>"
      bodyhtml <<  FocusApi::DisplayEmail.display_email_job(template_id,img_url,member_id,campaign_id,to_name,to_email,href,ipstr)
      #bodyhtml << %Q{<img src="http://#{ipstr}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
      bodyhtml << "</body>"
      puts "*"*10
      puts bodyhtml
      mail = Mail.new do
        to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email
        from    from
        message_id '<' + Time.now().to_f.to_s + '@' + Time.now().to_f.to_s.split(".")[1] + '.com>'
        subject subject
  
        html_part do
          content_type 'text/html; charset=UTF-8'
          content_id '<' + Time.now().to_f.to_s + '@' + Time.now().to_f.to_s.split(".")[1] + '.com>'
          content_transfer_encoding 'base64'
          body Base64.encode64(bodyhtml)
        end
      end
      filename = to_email.split("@").join("-")+"_" + Time.now().strftime("%Y%m%d%H%M%S") +".eml"
      sendmail = File.join(filepath, filename)

      puts sendmail
      file = File.open(sendmail,"w")
      hfrom = to_email.to_s.split("@")[0] + "_#{campaign_id}_0@" + domainstr.to_s
      strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + hfrom + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
      #strfile = Time.now().to_i.to_s + " 00" + " A\"#{email_smtp}:#{email_port.to_s}\":#{email_name.index('@') > 0 ? "\"#{email_name}\"" : email_name}:\"#{email_pwd}\" \r\n" + "F" + email_name + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
      strfile << mail.to_s
      puts mail.class
      puts mail.to_s
      file.print(strfile.gsub!(/\r\n/, "\n"))
      file.close

      return filename
    end
    
  end
end
