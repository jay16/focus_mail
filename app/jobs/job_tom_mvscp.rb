class Job_tom_mvscp
  @queue = "job_Tom"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      tomid = 0
      tomfns = ""
      tomfilenames = [
        "205&mqueue_tom_eth0",
        "205&mqueue_tom_eth1",
        "205&mqueue_tom_eth2" 
      ]
      sendmail = readfile["sendmail"].to_s + "tom/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if tomid < tomfilenames.count then
              tomfns = tomfilenames[tomid]
              tomid += 1
            else
              tomid = 0
              tomfns = tomfilenames[tomid]
              tomid += 1
            end
            toms = tomfns.split("&")
            filename = toms[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if toms[0].to_i == 206 then
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
