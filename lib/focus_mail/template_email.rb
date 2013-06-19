require 'mail'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'

module FocusMail
  module TemplateEmail
    def self.email_with_template_job(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url,user_id,email_smtp,email_port,email_domain,login_name,email_pwd,email_name,ipstr,domainstr,filepath)
      readfile = YAML.load_file('config/readfile.yml')
      readip = readfile["sendip"]
      readport = readfile["sendport"]
      bodyhtml = "<body>"
      bodyhtml <<  FocusMail::DisplayEmail.display_email_job(template_id,img_url,member_id,campaign_id,to_name,ipstr)
      bodyhtml << %Q{<img src="http://#{ipstr}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
      #bodyhtml << "<div style='display:none'>#{Kxword.find(rand(28331)+1).content.strip}</div>"
      #bodyhtml << "<div style='display:none'>#{Kxword.find(rand(28331)+1).content.strip}</div>"
      bodyhtml << "</body>"
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
      filename = member_id.to_s + "_" + Time.now().to_f.to_s
      sendmail = filepath + "/#{filename}.eml"
      file = File.open(sendmail,"w")
      hfrom = to_email.to_s.split("@")[0] + "_#{campaign_id}_0@" + domainstr.to_s
      strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + hfrom + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
      #strfile = Time.now().to_i.to_s + " 00" + " A\"#{email_smtp}:#{email_port.to_s}\":#{email_name.index('@') > 0 ? "\"#{email_name}\"" : email_name}:\"#{email_pwd}\" \r\n" + "F" + email_name + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
      strfile << mail.to_s
      file.print(strfile.gsub!(/\r\n/, "\n"))
      file.close
      create_email_log(template_id,hfrom,to_email,subject,user_id,campaign_id)
    end
    
    def self.create_email_log(template_id,hfrom,to_email,subject,user_id,campaign_id)
      CemailLog.create({
        :campaign_id => campaign_id,
        :template_id => template_id,
        :from_email => hfrom,
        :to_eamil => to_email,
        :subject => subject,
        :user_id => user_id
      })
    end
  end
end