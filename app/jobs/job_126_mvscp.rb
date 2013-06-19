class Job_126_mvscp
  @queue = "job_126"
  def self.perform
    if File.exists?('config/readfile.yml')
      readfile = YAML.load_file('config/readfile.yml')
      w126id = 0
      w126fns = ""
      w126filenames = [
        "205&mqueue_126_eth0", 
        "205&mqueue_126_eth1",
        "205&mqueue_126_eth2",
        "205&mqueue_126_eth3",
        "205&mqueue_126_eth4",
        "205&mqueue_126_eth5",
        "205&mqueue_126_eth6",
        "205&mqueue_126_eth7" 
      ]
      sendmail = readfile["sendmail"].to_s + "126/"
      Dir.mkdir(sendmail) unless File.directory?(sendmail)
      Dir.entries(sendmail).each do |f|
        if f.index(".") != 0 then
          if f.index("..") != 0 then
            if w126id < w126filenames.count then
              w126fns = w126filenames[w126id]
              w126id += 1
            else
              w126id = 0
              w126fns = w126filenames[w126id]
              w126id += 1
            end
            w126s = w126fns.split("&")
            filename = w126s[1]
            filepath = readfile["filepath"].to_s + filename.to_s + "/spam/"
            documentpath = sendmail.to_s + f.to_s
            if w126s[0].to_i == 206 then
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
