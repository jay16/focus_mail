class Job_yahoo_mvscp
  @queue = "job_Yahoo"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      yahooid = 0
      yahoofns = ""
      yahoofilenames = [
        "205&mqueue_yahoo" 
      ]
      sendmail = readfile["sendmail"].to_s + "yahoo/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if yahooid < yahoofilenames.count then
              yahoofns = yahoofilenames[yahooid]
              yahooid += 1
            else
              yahooid = 0
              yahoofns = yahoofilenames[yahooid]
              yahooid += 1
            end
            yahoos = yahoofns.split("&")
            filename = yahoos[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if yahoos[0].to_i == 206 then
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
