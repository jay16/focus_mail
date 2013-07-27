require 'resolv'
require 'net/smtp'
require 'net/telnet'
require 'yaml/store'
require 'yaml'
require 'logger'
require 'fileutils'

module FocusAgent
  class Telnet
    @domains = %w(qq sina tom sohu yahoo gmail hotmail 126 163)
    @from = "solife_li@126.com"
    if Object.const_defined?("Rails") then
      @cwd = File.join(Rails.root,"lib","focus_agent")
    else
      @cwd  = Dir.pwd
    end
    @smtp_server_path = File.join(File.dirname(@cwd),"smtp_server")
    @telnet_log_path    = File.join(File.dirname(@cwd),"telnet_log")
    
    class << self
      
      #使用smtp验证,email符全email基本格式
      #che_email中按域名分组时已验证
      #返回值为数组,[FocusMail对应码,SMTP验证返回码]
      def verify(email)
        email.downcase!
        email.chomp!
        email_domain=email.match(/\@(.+)/)[1]
        domain  = get_domain(email_domain)

        @yaml_path  = File.join(@smtp_server_path,"#{domain}_smtp_server.yml")
        @logger = Logger.new(File.join(@telnet_log_path,"#{domain}_smtp.log"))
        @logger.formatter = proc do |severity, datetime, progname, msg|
         "#{datetime}: #{msg}\n"
        end
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"

        mail_server = get_server(email_domain)
        
        if mail_server.nil? then
          @logger.info("#{email},-2,#{domain},nil")
          return -2
        end
        
        begin
          telnet = Net::Telnet.new("Host" => mail_server,
             "Port" => 25,
             "Telnetmode" => false,
             "Telnetmode" => false,
             "Timeout" => 60)
          strcmd = "HELO openfind.com \nmail from:<> \nrcpt to:#{email} \n. \nquit \n"
          ret = telnet.cmd(strcmd)
          telnet.close
          ret_code = ret.split("\n")[3].split(" ")[0]
          #网络异常报什么错
        rescue Net::SMTPAuthenticationError, 
          Net::SMTPServerBusy, 
          Net::SMTPSyntaxError, 
          Net::SMTPFatalError, 
          Net::SMTPUnknownError => error
      
          ret_code = error.to_s[0..2].to_i 
        rescue IOError,
          TimeoutError,
          ArgumentError,
          Errno::EHOSTUNREACH => error
      
          ret_code = -1
        end
        if ret_code == "0" then
          focus_code = 0
        elsif ret_code == "250" then
          focus_code = 1
        elsif ret_code == "550" then
          focus_code = 2
        elsif ret_code == "553" then
          focus_code = 3
        elsif (ret_code =~/^45\d/) == 0 then
          focus_code = 4
        else
          focus_code = 5
        end 
        #statu = ret
        @logger.info("#{email},#{ret_code},#{focus_code},#{domain},#{mail_server}")

        return [focus_code,ret_code]
      end
    
      #获取smtp测试后的结果值
      def get_statu(response_code)
        rcpt_responses =
          {
             -1 => 0, #:fail,        # Validation failed (non-SMTP)
            250 => 1, #:valid,       # Requested mail action okay, completed
            251 => 5, #:dunno,       # User not local; will forward to <forward-path>
            450 => 4, #:valid_fails, # Requested mail action not taken:, mailbox unavailable
            451 => 4, #:valid_fails, # Requested action aborted:, local error in processing
            452 => 4, #:valid_fails, # Requested action not taken:, insufficient system storage
            421 => 4, #:fail,        # <domain> Service not available, closing transmission channel
            500 => 5, #:fail,        # Syntax error, command unrecognised
            501 => 5, #:invalid,     # Syntax error in parameters or arguments
            503 => 5, #:fail,        # Bad sequence of commands
            521 => 5, #:invalid,     # <domain> does not accept mail [rfc1846]
            550 => 2, #:invalid,     # Requested action not taken:, mailbox unavailable
            551 => 5, #:dunno,       # User not local; please try <forward-path>
            552 => 5, #:valid,       # Requested mail action aborted:, exceeded storage allocation
            553 => 3, #:invalid,     # Requested action not taken:, mailbox name not allowed
          }
      
        response_code = (rcpt_responses.has_key?(response_code) ? response_code : -1)
        return rcpt_responses[response_code]
      end
      
      #从本地获取email_domain的server,不存在则实时更新
      def get_server(email_domain)
        yaml_save = YAML::Store.new(@yaml_path)

        if File.exist?(@yaml_path) then
          yaml_load = YAML.load_file(@yaml_path)
          if yaml_load[email_domain] then
            #该邮箱域名可测试得通
            if yaml_load[email_domain][:is_valid] then 
              hash = get_min_preference(yaml_load[email_domain][:mx])
              puts "MX:#{hash.to_s}"
              return hash[:exchange]
            else
              return nil
            end
          else
             hash = save_to_yaml(yaml_save,email_domain)
             return hash.has_key?(:exchange) ? hash[:exchange] : nil
          end
        else
           hash = save_to_yaml(yaml_save,email_domain)
           return hash.has_key?(:exchange) ? hash[:exchange] : nil
        end
        
      end
      
      #获取email_domain的mx的exchange,prigrille
      def get_servers(email_domain)
        dns = Resolv::DNS.open
        mail_servers = dns.getresources(email_domain, Resolv::DNS::Resource::IN::MX)
        mx_array = []
        if mail_servers.size > 0 then 
          mail_servers.each do |server|
            next if server.preference.nil?
            mx_array << { :preference => server.preference,:exchange => server.exchange.to_s}
          end
        end
        return mx_array
      end
      
      #对应邮箱域名mx记录不存在或更新后写入yaml
      def save_to_yaml(yaml_save,email_domain)
        mx_array = get_servers(email_domain)
        
        yaml_save.transaction do
          yaml_save[email_domain] = {
            :is_valid => mx_array.size > 0 ? 1 : 0,
            :update   => Time.now.to_i,
            :strftime => Time.now.strftime("%y-%m-%d %H:%M:%S"),
            :mx       => mx_array
          }
        end
        
        return get_min_preference(mx_array)
      end
      
      #取perference最小值 的那组server
      def get_min_preference(mx_array)
        if mx_array.size == 0 then 
          return {}
        elsif mx_array.size == 1 then
          return mx_array[0]
        else
          #取preference最小值的那组
          sort = mx_array.sort { |x, y| x[:preference] <=> y[:preference] }
          return sort[0]
        end
      end
      
      def get_domain(email_domain)
         domain = nil
         @domains.each do |dd|
          domain = dd if email_domain =~ /#{dd}/
         end
         return (domain.nil? ? "other" : domain)
      end
    end
  end
end
