class Job_QQ_mvscp
  @queue = "job_QQ"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      qqid = 0
      qqfns = ""
       qqfilenames = [
         "205&mqueue_qq_eth0",
         "205&mqueue_qq_eth1",
         "205&mqueue_qq_eth2",
         "205&mqueue_qq_eth3",
         "205&mqueue_qq_eth4",
         "205&mqueue_qq_eth5",
         "205&mqueue_qq_eth6",
         "205&mqueue_qq_eth7",
         "206&mqueue_qq_eth0",
         "206&mqueue_qq_eth1",
         "206&mqueue_qq_eth2",
         "206&mqueue_qq_eth3",
         "206&mqueue_qq_eth4" 
      ]
      sendmail = readfile["sendmail"].to_s + "qq/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)

      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if qqid < qqfilenames.count then
              qqfns = qqfilenames[qqid]
              qqid += 1
            else
              qqid = 0
              qqfns = qqfilenames[qqid]
              qqid += 1
            end
            qqs = qqfns.split("&")
            filename = qqs[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if qqs[0].to_i == 206 then
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
