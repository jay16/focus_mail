require 'resque'
class Job
  @queue = "job_test1"
  def self.perform(from, to_email, to_name, member_id, subject, campaign_id, template_id, img_url)
    abc = 'rails.png@ddee.eer'
    bodyhtml = Job.new.display_email(template_id,img_url)
    mail = Mail.new do
      to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email
      from    from
      subject subject
    
      html_part do
        content_type 'text/html; charset=UTF-8'
        body bodyhtml.to_s + '<h1>This is HTML</h1>'
      end
    end
    readfile = YAML.load_file('config/readfile.yml')
    sendmail = readfile["sendmail"].to_s + "#{filename}.eml"
    file = File.open(sendmail,"w")
    strfile = Time.now().to_i.to_s + " 00\r\n" + "F" + from + "\r\n" + "R" + to_email + "\r\n" + "E\r\n"
    strfile << mail.to_s
    file.print(strfile)
    file.close
  end
  
  def display_email(template_id,img_url)
    template = Template.find(template_id)
    entries = Entry.find_all_by_template_id(template_id)
    source = IO.readlines(Rails.root.join('lib/emails', "#{template.file_name}.html.erb")).join("").strip
    source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")
    entries.each do |e|
      if e.name.include? "img" then
        if img_url == 1 then
          source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
        else
          source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{Rails.configuration.host_with_port}/public/images/" + e.default_value)
        end
        
      else
        source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
      end
    end
    return source.lstrip
  end
end