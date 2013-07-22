require 'zip/zip'
require 'zip/zipfilesystem'
require 'uri'
require 'nokogiri'
require 'cgi'

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

  def source= (val)
    #p Rails.configuration.splitor_start
    #p Rails.configuration.splitor_end
    if val != "" && val != nil then    

       #分析html代码，读取href,image地址 
       val = deal_html(val) 

      File.open(Rails.root.join("lib/emails", "#{self.fname}.html.erb"), 'wb'){ |f| f.write(val) }
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
    #allow to use $|.|$ in template source code
    #val = val.gsub(/Dear \$\|NAME\|\$ <br\/>/, "")
    #val = val.gsub(/from \$\|EMAIL\|\$ <br\/>/, "")

    val = val.chomp.strip
    return val unless val
    
    @astr = Array.new(){Array.new(2,0)}
    @gi = 0
    #hval : href val #ival : image val
    hval = Array.new
    ival = Array.new
    
    doc = Nokogiri::HTML(val)
    doc.css("img").each_with_index do |img, index|
      img_src = img.attr("src")
      #image src以http或https开头不存入库，跳过
     #不在此处过滤，会虚增@astr空间
      next if %r{^(http|https)://(.*)}.match(img_src)
      
      ival.push(img_src)
      img["src"] = "$|img#{@gi}|$"
      if img_src != "" && img_src != nil then
          srcs     = img_src.split("/")
          img_src  = srcs[srcs.length-1]
      end
      @astr[@gi] = ["img#{@gi}",img_src]
      @gi += 1
    end
    
    doc.css("a").each_with_index do |hyper, index|
      hyper_href = hyper.attr("href")
      unsub_url = "http://220.248.30.60/unsubscribe".gsub("/","\/")
      
      uri = URI.parse(hyper_href)
      if uri.scheme then
        #为每个Href添加l=timestamp进行唯一标识
        #to_i精确到秒s,同一秒处理的链接也有重合
        hyper_href << (uri.query ? "&" : "?" )
        hyper_href << "l=#{Time.now.to_i}#{index}"
      else
        hyper_href = "javascript:void(0);l=#{Time.now.to_i}#{index}"
      end
      #新拼接的href写回源代码
      #退订链接特殊处理：数据库仅存链接，模板上保留?cid=$|CID|$&email=$|EMAIL|$
      if hyper_href =~ /#{unsub_url}/ then
        hyper["href"] = "$|href#{@gi}|$&cid=$|CID|$&email=$|EMAIL|$"
      else
        hyper["href"] = "$|href#{@gi}|$"
      end
      hval.push(hyper_href)
      @astr[@gi] = ["href#{@gi}",hyper_href]
      @gi += 1
    end
    

   return CGI.unescape(doc.to_s)
  end

end
