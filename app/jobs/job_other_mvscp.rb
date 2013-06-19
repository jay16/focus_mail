class Job_other_mvscp
  @queue = "job_Other"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      otherid = 0
      otherfns = ""
      otherfilenames = [
        "205&mqueue"
      ]
      sendmail = readfile["sendmail"].to_s + "other/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if otherid < otherfilenames.count then
              otherfns = otherfilenames[otherid]
              otherid += 1
            else
              otherid = 0
              otherfns = otherfilenames[otherid]
              otherid += 1
            end
            others = otherfns.split("&")
            filename = others[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if others[0].to_i == 206 then
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
