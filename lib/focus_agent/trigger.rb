require 'json'
require "open-uri" 

module FocusAgent
  class Trigger
    def self.fork(tar_path,id,mail_type)
      
      if mail_type == 0
         puts "Inner Test"
      else
        puts "Other Function Is Developing"
        return false
      end
      
      if File.exist?(tar_path) then
          sdate = Time.now.to_i
          #mail_type 0 内测; 1 搬信
          url = "http://166.63.126.33:3456/mailer/listener.json?cid=#{id}&sdate=#{sdate}&mail_type=#{mail_type}"
          html_response = nil  
          begin
            puts "*"*10
            puts url
            puts "trigger"
            open(url) { |http| html_response = http.read }
          rescue => e
            puts "*"*10
            puts e.message
          else
            json_body = JSON.parse(html_response)
          end
      else
        puts "ERROR:NOT EXIST - #{tar_path}"
      end
    end
  end
end