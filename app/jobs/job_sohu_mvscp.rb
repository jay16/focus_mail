class Job_sohu_mvscp
  @queue = "job_Sohu"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      sohuid = 0
      sohufns = ""
      sohufilenames = [
        "205&mqueue_sohu" 
      ]
      sendmail = readfile["sendmail"].to_s + "sohu/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if sohuid < sohufilenames.count then
              sohufns = sohufilenames[sohuid]
              sohuid += 1
            else
              sohuid = 0
              sohufns = sohufilenames[sohuid]
              sohuid += 1
            end
            sohus = sohufns.split("&")
            filename = sohus[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if sohus[0].to_i == 206 then
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
