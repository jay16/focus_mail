require 'fileutils'

module FocusAgent
  #理想状态下，全部旧文件都标志为avoid_reuse
  class Avoid
    #避免要在某文件夹内生成信时，此文件夹已存在
    #修改已存在文件夹名称，并标志
    def self.conflict(path)
       mv(path,"avoid_conflict")
    end
    
    #避免某文件夹内生成信已经使用，下次生成信时失败，
    #误把此旧文件夹做为新生成文件夹使用
    def self.reuse(path)
       mv(path,"avoid_reuse")
    end
    
    def self.mv(path,extname)
      avoid_extname = %Q{#{Time.now.strftime('%y%m%d%H%M%S')}.#{extname}}
      
      if File.exist?(path) or File.exists?(path)
        FileUtils.mv(path,"#{path}_#{avoid_extname}")
        
        if File.directory?(path)
          tar_file = "#{path}.tar.gz"
          FileUtils.mv(tar_file,"#{tar_file}_#{avoid_extname}") if File.exists?(tar_file)
        end
      end
    end
  end
end