#encoding: utf-8
require './smtp_ret'
  
  domain_path = ARGV[0]
  
  cwd           = Dir.pwd
  smtp_log_path = File.join(File.dirname(cwd),"smtp_log")
  logger = Logger.new(File.join(smtp_log_path,"smtp_fatal.log"))
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
  end

  lines  = File.readlines(domain_path)
  emails = lines.grep(/@/)
  result_path = "#{domain_path}_result.csv"

  #如果由于未知原因中断，重新验证时，应从上次中断位置开始验证
  if File.exist?(result_path) then
    result_len =  File.readlines(result_path).size
    emails_len = emails.size
    emails = emails[result_len...emails_len] #result_len =< .. < emails_len
  end

  emails.each_with_index do |email,index|
    email.downcase!
    begin
      ret = FocusAgent::SMTP.verify(email)
    rescue => e
      logger.info("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')},#{email},#{index}")
      e.backtrace.each { |row| logger.info("#{row}") }
    else
      File.open(result_path,"a") { |file| file.puts "#{email},#{ret}" }
    end
  end
