require 'mail'
module FocusMail
  module GmTest
    def self.gradetest(template_id, user_email, fname)
      from_name = to_email = to_name = from_email = from = user_email
      subject = fname
      mailfile = email_with_template_job(from_email, from, to_email, to_name, 1, subject, 1, template_id, 2, 1)
      strgrade = "/mailgates/mg/bin/mbf_client #{mailfile}"
      numgrade = `#{strgrade}`
      numgrade = numgrade.chomp.split("ret")[1].strip
      Template.update(template_id,:grade => numgrade)
    end
    
    def self.email_with_template_job(hfrom, from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url,user_id)
      readfile = YAML.load_file('config/readfile.yml')
      readip = readfile["sendip"]
      readport = readfile["sendport"]
      bodyhtml = "<body>"
      bodyhtml << display_email_job(template_id,img_url,member_id,campaign_id)
      bodyhtml << %Q{<img src="http://#{readip}:#{readport}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
      bodyhtml << "</body>"
      
      mail = Mail.new do
        to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email
        from    from
        reply_to "replyto_" + campaign_id.to_s + "_" + user_id.to_s + readfile["reply"].to_s
        subject subject
      
        html_part do
          content_type 'text/html; charset=UTF-8'
          body bodyhtml.to_s
        end
      end
      filename = to_name + Time.now().to_f.to_s
      sendmail = readfile["mgtest"].to_s + "#{filename}.eml"
      file = File.open(sendmail,"w")
      strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + hfrom + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
      strfile << mail.to_s
      file.print(strfile.gsub!(/\r\n/, "\n"))
      file.close
      return sendmail
    end
    
    def self.display_email_job(template_id,img_url,member_id,campaign_id)
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
          if %r{^http://(.*)}.match(e.default_value)
            link = Link.where(:url => v).first_or_create
            v = "http://#{readip}:#{readport}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
            source = source.gsub(/\$\|#{e.name}\|\$/, v)
          else
            source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
          end
        end
      end
      return source.lstrip.to_s
    end
  end
end
