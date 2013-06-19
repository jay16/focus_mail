class Job_sina_mvscp
  @queue = "job_Sina"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      sinaid = 0
      sinafns = ""
      sinafilenames = [
        "205&mqueue_sina",
        "205&mqueue_sina_eth0",
        "205&mqueue_sina_eth1",
        "205&mqueue_sina_eth2" 
      ]
      sendmail = readfile["sendmail"].to_s + "sina/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if sinaid < sinafilenames.count then
              sinafns = sinafilenames[sinaid]
              sinaid += 1
            else
              sinaid = 0
              sinafns = sinafilenames[sinaid]
              sinaid += 1
            end
            sinas = sinafns.split("&")
            filename = sinas[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if sinas[0].to_i == 206 then
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
