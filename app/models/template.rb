require 'zip/zip'
require 'zip/zipfilesystem'
class Template < ActiveRecord::Base
  after_create :dog_logger
  attr_accessible :file_name, :name,:img_url, :source, :zip_url, :zip_name, :org_id, :user_email, :grade, :fname
  has_many :entries
  has_many :campaigns
  File_extname = [".rar",".7z",".zip"]
  File_target = "public/files"
 
  def user_email
    return @user_email
  end
  
  def user_email= (val)
    @user_email = val    
  end

  def org_id
    return @orgid
  end
  
  def org_id= (val)
    @orgid = val
  end  

  def fname
    return @fname
  end
  
  def fname= (val)
    @fname = val
  end 

  def set_file_values(file_url,file_name)
    self.zip_url = file_url
    self.zip_name = file_name
  end

  def source
    if self.file_name
      @source = IO.readlines(Rails.root.join('lib/emails', "#{self.file_name}.html.erb")).join("").strip
    end
  end
  
  @astr = "nil"

  #处理直接贴html代码
  def source= (val)
    if val != "" && val != nil then   
      
      #分析html代码，读取href,image地址 
      val = deal_html(val)
      
      File.open(Rails.root.join("lib/emails", "#{self.fname}.html.erb"), 'wb'){ |f| f.write(val) }
      #puts @astr
      else
        File.open(Rails.root.join("lib/emails", "#{self.fname}.html.erb"), 'wb')
    end
  end
  
  def dog_logger
    @Template = Template.where(["file_name = :f", { :f => self.file_name }]).first
    if @astr != nil then
      Entry.delete_all("template_id=#{@Template.id}")
      @astr.each do |a|
        Entry.create({
          :template_id => @Template.id,
          :name => a[0].to_s,
          :default_value => a[1].to_s
        })
      end
      if @Template != nil then
        @Template.update_attributes(:zip_url => nil, :zip_name => nil) 
      end
     puts "upload file"
    else
      if self.zip_name != "" && self.zip_name != nil then
        Entry.delete_all("template_id=#{@Template.id}")
        zipfile_name = Rails.root.join(File_target, self.zip_url)
        zipfile_path = zipfile_name.to_s.split(".")[0]
        FileUtils.makedirs(zipfile_path)
        Zip::ZipFile::open(zipfile_name.to_s) do |zf|
          zf.each do |e|
             fpath = File.join(zipfile_path, e.name)
             FileUtils.mkdir_p(File.dirname(fpath))
             zf.extract(e, fpath)
          end
        end
        if FileTest::exist?(File.join(zipfile_path, "index.html")) then
          val = File.open(File.join(zipfile_path, "index.html")).read
          
          #分析html代码，读取href,image地址 
          val = deal_html(val) 

          File.open(Rails.root.join("lib/emails", "#{self.file_name}.html.erb"), 'wb'){ |f| f.write(val) }
        end
        if @astr != nil then
          @astr.each do |a|
            Entry.create({
              :template_id => @Template.id,
              :name => a[0].to_s,
              :default_value => a[1].to_s
            })
          end
        end
      end
    end
    if self.user_email != nil then
      #FocusMail::GmTest::gradetest(@Template.id, self.user_email, self.name)
    end
    #修改上传文件的权限
    #system 'chown -R webmail:webmail /home/work/focus_mail/public/files'
  end
  
  #分析html代码，读取href,image地址
  #zip上传、html代码共用代码
  def deal_html(val)
    val = val.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    val = val.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")

    val = val.chomp.strip
    #if(val.include? "$|")
    #  val = val.lstrip 
    #else
    if val then
      #hval : href val 
      #ival : image val
      hval = val.scan(/<a[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      hval += val.scan(/<a[^>]*?HREF=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      hval += val.scan(/<A[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      hval += val.scan(/<A[^>]*?HREF=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      iival = val.scan(/<img[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      iival += val.scan(/<img[^>]*?SRC=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      iival += val.scan(/<IMG[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      iival += val.scan(/<IMG[^>]*?SRC=(['"\s]?)(([^'"\s])*)[^>]*?>/)
      
      ival = Array.new
      hh   = Array.new
      iival.each do |i1|
       #image src以http或https开头不存入库，跳过
       #不在此处过滤，会虚增@astr空间
       hh.push(i1) if %r{^(http|https)://(.*)}.match(i1[1])
      end
      
      ival = iival - hh
      
      num = hval.length+ival.length
      @astr = Array.new(num){Array.new(2,0)}

      #href image的index坐标
      @m = 0
      #href部分
      hvala = Array.new()
      hval.each do |hl|
        hvala.push hl[1]
      end
      hvala = hvala.sort.reverse
      slist = hvala.clone  
      for i in 0..(slist.length - 1)
        for j in 0..(slist.length - i - 2)
          if ( slist[j + 1].size <=> slist[j].size ) == -1
            slist[j], slist[j + 1] = slist[j + 1], slist[j]
          end
        end
      end
      #html部分
      num = slist.length-1
      for n in 0..num
        val = val.gsub(Regexp.new(slist[num-n].to_s.gsub(/\?/,'\?').gsub(/\$/,'\$')), "$|href" + @m.to_s + "|$")
        @astr[@m][0] = "href" + @m.to_s
        @astr[@m][1] = slist[num-n].to_s
        @m += 1
      end
      #img部分
      ival.each do |i1|
        val = val.gsub(Regexp.new(i1[1]), "$|img" + @m.to_s + "|$")
        @astr[@m][0] = "img" + @m.to_s
        urlimg = i1[1].to_s
        if urlimg != "" && urlimg != nil then
          urlimgs = urlimg.split("/")
          uinum = urlimgs.length
          urlimg = urlimgs[uinum-1]
        end
        @astr[@m][1] = urlimg.to_s
        @m += 1

      end
      val = val.lstrip 
    end
  end
  
end
