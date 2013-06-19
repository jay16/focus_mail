class Job_163_mvscp
  @queue = "job_163"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      w163id = 0
      w163fns = ""
      w163filenames = [
        "205&mqueue_163_eth0",
        "205&mqueue_163_eth1",
        "205&mqueue_163_eth2",
        "205&mqueue_163_eth3" 
      ]
       # "205&mqueue_163_eth4" 
      sendmail = readfile["sendmail"].to_s + "163/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if w163id < w163filenames.count then
              w163fns = w163filenames[w163id]
              w163id += 1
            else
              w163id = 0
              w163fns = w163filenames[w163id]
              w163id += 1
            end
            w163s = w163fns.split("&")
            filename = w163s[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if w163s[0].to_i == 206 then
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
