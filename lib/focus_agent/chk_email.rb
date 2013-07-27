require 'fileutils'

module FocusAgent
  class ChkEmail
    @domains = %w(qq sina tom sohu gmail hotmail yahoo 163 126)
    
    class << self
      def dispatch(file_path)
        base_name = File.basename(file_path)
        dir_path  = File.dirname(file_path)
        pid_file  = "#{file_path}.pid"
	tmp_pid   = File.join(dir_path,"tmp_#{Time.now.to_i}_pid")
        log_file  = "#{file_path}.log"
        
        lines  = File.readlines(file_path)
        emails = lines.grep(/@/).uniq
        File.open(log_file,"a+") { |file| file.puts "emails,#{emails.size}" }
        
        run_backer = File.join(dir_path,"run_backer.rb")
        
        other_emails = emails
        @domains.each do |domain|
          domain_emails = emails.grep(/@(vip.|)#{domain}./i).uniq
          File.open(log_file,"a+") { |file| file.puts "#{domain},#{domain_emails.size}" }
          
          domain_file   = "#{base_name}.#{domain}.com"
          domain_path   = File.join(dir_path,domain_file)
          other_emails -= domain_emails
          File.open(domain_path,"w+") { |file| file.puts domain_emails }
          
          system("nohup ruby #{run_backer} #{domain_path} #{domain} & echo $! > #{tmp_pid} &")
          
          pid = File.readlines(tmp_pid)[0].to_i
          File.open(pid_file,"a+") { |file| file.puts "#{domain_file},#{pid}" }
        end
        
        other_file = "#{base_name}.other"
        other_path = File.join(dir_path,other_file)
        File.open(log_file,"a+") { |file| file.puts "other,#{other_emails.size}" }
        File.open(other_path,"w+") { |file| file.puts other_emails }

        system("nohup ruby #{run_backer} #{other_path} other & echo $! > #{tmp_pid} &")
          
        pid = File.readlines(tmp_pid)[0].to_i
        File.open(pid_file,"a+") { |file| file.puts "#{other_file},#{pid}" }
	FileUtils.rm(tmp_pid)
      end

      def rechk(file_path)
        base_name = File.basename(file_path)
        dir_path  = File.dirname(file_path)
        pid_file  = "#{file_path}.pid"
	tmp_pid   = File.join(dir_path,"tmp_#{Time.now.to_i}_pid")
        log_file  = "#{file_path}.log"
        
        run_backer = File.join(dir_path,"run_backer.rb")
        @domains.each do |domain| 
          domain_file   = "#{base_name}.#{domain}.com"
          domain_path   = File.join(dir_path,domain_file)

          system("nohup ruby #{run_backer} #{domain_path} #{domain} & echo $! > #{tmp_pid} &")
          
          pid = File.readlines(tmp_pid)[0].to_i
          File.open(pid_file,"a+") { |file| file.puts "#{domain_file},#{pid}" }
        end
        
        other_file = "#{base_name}.other"
        other_path = File.join(dir_path,other_file)

        system("nohup ruby #{run_backer} #{other_path} other & echo $! > #{tmp_pid} &")
          
        pid = File.readlines(tmp_pid)[0].to_i
        File.open(pid_file,"a+") { |file| file.puts "#{other_file},#{pid}" }
	FileUtils.rm(tmp_pid)
      end
      
      def chk_email(domain_path)
        lines  = File.readlines(file_path)
        emails = lines.grep(/@/)
        result_path = "#{domain_path}_result.csv"
        emails.each_with_index do |email,index|
          ret = FocusAgent::SMTP.verify(email)
          File.open(result_path,"a") { |file| file.puts "#{email},#{ret}" }
        end
      end
      
    end
  end
end
