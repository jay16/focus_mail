class FocusMailer < ActionMailer::Base
  #include Resque::Mailer
  include ApplicationHelper

  #default from: "neosoyn@gmail.com"
  default from: "user08@cndemo.openfind.com"

  def test_email
    mail(to: 'neosoyn@gmail.com', subject: 'Email test')
  end

  def send_email(from, to, subject, body)
    mail(from: from, to: to, subject: subject) do |format|
      format.text { render text: body}
      format.html { render text: "#{body}" }
    end
  end

  def send_email_with_template(from, to_email, to_name, member_id, subject, campaign_id)
    to = to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email
    mail(from: from, to: to, subject: subject) do |format|
      source = replace_email_source(campaign_id, member_id)
      source = source.gsub(/\$\|NAME\|\$/, to_name)
      source = source.gsub(/\$\|EMAIL\|\$/, to_email)
      source = source.gsub(/\$\|SUBJECT\|\$/, subject)

      # add track code to monitor email open
      body = "<body>"
      body << source
      body << %Q{<img src="http://#{Rails.configuration.host_with_port}/track.gif?c=#{campaign_id}&u=#{member_id}" style="display:none" />}
      body << "</body>"

      format.text { render text: body}
      format.html { render text: "#{body}" }
    end
  end
  
  def email_with_template(from, to_email, to_name, member_id, subject, campaign_id)
    abc = 'ddede@ddee.eer'
    mail = Mail.new do
      to      to_name.present? ? %{"#{to_name}" <#{to_email}>} : to_email #'yy_lfy@126.com'
      from    from #'eric yue <eric_yue@intfocus.com>'
      subject subject #'First multipart email sent with Mail大口大口的'
    
      #text_part do
       # body 'This is plain text'
      #end
    
      html_part do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1><img width=16 height=16 src="cid:' + abc + '">'
      end
      #add_file '/home/work/vicm.png'
    end
    mail.attachments['vicm.png'] = {:mime_type => 'application/x-gzip',:content_id => abc,:content => File.read('/home/work/vicm.png')}
    puts mail.to_s
    readfile = YAML.load_file('config/readfile.yml')
    sendmail = readfile["sendmail"].to_s + "#{filename}.eml"
    file = File.open(sendmail,"w")
    #file = File.new("/home/work/#{to_name}.eml","w")
    file.print(mail.to_s)
    file.close
  end

end
