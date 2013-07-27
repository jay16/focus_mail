require 'mail'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'

module FocusApi
  module DisplayEmail
    def self.display_email_job(template_id,img_url,member_id,campaign_id,to_name,to_email,href,ipstr)
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
      #member_email = Member.find(member_id).email
      member_email  = to_email
      source = source.gsub(/\$\|EMAIL\|\$/, member_email)
      source = source.gsub(/\$\|NAME\|\$/, to_name)
      source = source.gsub(/\$\|HREF\|\$/, href)
      return source.lstrip.to_s
    end
  end
end
