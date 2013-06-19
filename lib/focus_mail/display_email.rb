require 'mail'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'

module FocusMail
  module DisplayEmail
    def self.display_email_job(template_id,img_url,member_id,campaign_id,to_name,ipstr)
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
      member_email = Member.find(member_id).email
      source = source.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
      source = source.gsub(/from \$\|EMAIL\|\$ <br\/>/, member_email)
      source = source.gsub(/\$\|CID\|\$/, campaign_id.to_s)
      source = source.gsub(/\$\|EMAIL\|\$/, member_email)
      source = source.gsub(/\$\|NAME\|\$/, to_name)
      entries.each do |e|
        if e.name.include? "img" then
          if img_url == 1 then
            source = source.gsub(/\$\|#{e.name}\|\$/, "cid:" + e.default_value.to_s)
          else
            if(e.default_value.to_s=~/http:\/\/([\w-]+\.)+[\w-]+(\/[\w-]*)?.*/) != nil then
              source = source.gsub(/\$\|#{e.name}\|\$/, e.default_value)
            else
              source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{ipstr}:#{readport}#{images}" + e.default_value)
              #source = source.gsub(/\$\|#{e.name}\|\$/, "http://#{readip}:#{readport}#{images}" + e.default_value)
            end
          end
          
        else
          v = e.default_value
          if %r{^(http|https)://(.*)}.match(e.default_value)
            link = Link.where(:url => v).first_or_create
            v = "http://#{ipstr}:#{readport}/click?u=#{member_id}&c=#{campaign_id}&l=#{link.id}"
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
