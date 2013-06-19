class Job_hotmail_mvscp
  @queue = "job_Hotmail"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      hotmailid = 0
      hotmailfns = ""
      hotmailfilenames = [
        "205&mqueue"
      ]
      sendmail = readfile["sendmail"].to_s + "hotmail/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if hotmailid < hotmailfilenames.count then
              hotmailfns = hotmailfilenames[hotmailid]
              hotmailid += 1
            else
              hotmailid = 0
              hotmailfns = hotmailfilenames[hotmailid]
              hotmailid += 1
            end
            hotmails = hotmailfns.split("&")
            filename = hotmails[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if hotmails[0].to_i == 206 then
              strmvs = "mv #{documentpath} #{filepath}"
            else
              strmvs = "scp #{documentpath} 210.14.76.205:#{filepath}"
            end
            #`#{strmvs}`
            #`rm -fr #{documentpath}`
            #shell命令执行成功则删除原eml,否则留到下次搬运
            if system(strmvs) then
              `rm -f #{documentpath}`
               #在nohup里留下搬运记录，为缺信，漏信提供依据
               puts strmvs
            end
          end
        end
      end
    end
  end
end
