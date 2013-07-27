require 'yaml'
require 'yaml/store'
require 'json'
require "open-uri" 

    def run_command(cmd, exit_on_error=false)
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

    def trigger(to_email,mail_tar,md5,strftime)
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
      puts "json_body;#{json_body}"
    end
    strftime =  "20130727132446"
    email    = "jay_li@intfocus.com"
    tar_name = "jay_li-intfocus.com_20130727132446.eml.tar.gz"
    md5      = "fe3dba194bc92464233c6551ceba6b27"

    #trigger(email,tar_name,md5,strftime)

    def getstate(to_email)
      focus_agent = "http://220.248.30.58:6669/open/getstate" 
      p_str       = "email=#{to_email}"

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
      puts "json_body;#{json_body}"
    end
    getstate("solife_li@163.com")
