require 'yaml'
require 'yaml/store'
require 'json'
require "open-uri" 

module FocusApi
  class MailAgent
    def self.transfer(to_email,filename)

      api_path    = Rails.root.join("public/openapi")
      yml_path    = File.join(api_path,"#{to_email.split('@').join('-')}.yaml")

      mail_path   = File.join(api_path,filename)

      puts "*"*10
      puts "to email :#{to_email}"

      yaml_save = YAML::Store.new(yml_path)
      
      strftime = Time.now().strftime("%Y%m%d%H%M%S")
      yaml_save.transaction do
	yaml_save[strftime] = {
	  :time      => strftime,
	  :to_email  => to_email,
	  :file_name => filename,
	 }
      end

      mail_tar    = "#{filename}.tar.gz"
      if File.exist?(mail_path) then
	system("cd #{api_path} && tar -czvf #{mail_tar} #{filename}")
      else
	puts "NOT EXIST:#{filename}"
      end
      tar_path = File.join(api_path,mail_tar)

      if File.exist?(tar_path) then
	ret = run_command("cd #{api_path} && md5sum #{mail_tar}") 
	md5 = ret[0].split(" ")[0].chomp
      else
	md5 = nil
      end

      yaml_save.transaction do
	yaml_save[strftime][:tar_name] = mail_tar
	yaml_save[strftime][:md5] = md5
      end

      res_json = trigger(to_email,mail_tar,md5,strftime)
      puts res_json

      yaml_save.transaction do
	yaml_save[strftime][:link_state] = res_json[:code]
	yaml_save[strftime][:link_info]  = res_json[:info]
	
      end
    end

    def self.trigger(to_email,mail_tar,md5,strftime)
      focus_agent = "http://166.63.126.33:3456/open/mailer" 
      #focus_agent = "http://113.196.70.18:3456/open/mailer" 
      p_str       = "email=#{to_email}&tar_name=#{mail_tar}&strftime=#{strftime}&md5=#{md5}"

      url = "#{focus_agent}?#{p_str}"
      html_response = nil  
      begin
	open(url) { |http| html_response = http.read }
      rescue => e
	puts e.message
	json_body = nil
      else
	json_body = JSON.parse(html_response)
      end

      return json_body
    end

    def self.run_command(cmd, exit_on_error=false)
      ret = []
      IO.popen(cmd) do |stdout|
	stdout.each do |line|
	  next if line.nil?
	  ret << line
	end 
      end 
    
      if exit_on_error && ($?.exitstatus != 0)
	$stderr.puts "command failed:\n#{cmd}"
	return []
      end 
    
      ret 
    end
  end
end
