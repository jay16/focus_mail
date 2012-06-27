class EntriesController < ApplicationController
  before_filter :create_template, :only =>[:new, :new_image, :edit, :create, :update,
                                           :destroy, :auto_create_email_template] 
  after_filter :auto_create_email_template, :only => [:create, :edit, :update, :destroy]
  after_filter :auto_check_template_img_dir, :only => [:destroy]
  
  def new
    @entry = @template.entries.build
    params[:entry_type] = "entry_link"

    respond_to do |format|
      format.js
    end
  end
  
  def new_image
    @entry = @template.entries.build
    params[:entry_type] = "entry_image"

    respond_to do |format|
      format.js { render "entries/new.js.erb" }
    end
  end
  

  def edit
    @entry = @template.entries.find(params[:id])
    @is_image = is_img_entry(@entry)
    @img_path = img_path(@entry) if @is_image
    
    respond_to do |format|
      format.js
    end
  end

  def create
    @entry = @template.entries.create(params[:entry])   
    
     if deal_with_image_entry(@template,@entry,params[:image],true)
      @is_image = true
      @img_path = img_path(@entry)
     end
 
    respond_to do |format|
      if @entry.save
        format.js
      else
        format.js { render action: "new" }
      end
    end
  end

  def update
    @entry = @template.entries.find(params[:id])
    
    deal_with_image_entry(@template,@entry,params[:image],false)

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        format.js
      else
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @entry = @template.entries.find(params[:id])
    
    file_path = "#{@entry.default_value}"
    dir_path = File.dirname(file_path)
    if File.file?(file_path)
				  File.delete(file_path) 
				  Dir.rmdir(dir_path) if File.exists?(dir_path)
    end
    @entry.destroy

    respond_to do |format|
      format.js
    end
  end
  
  def create_template
    @template = Template.find(params[:template_id])
  end
  
  def is_img_entry(entry)
    entry.default_value.present?&&File.file?("#{entry.default_value}")
  end
  
  def img_path(entry)
    "#{entry.default_value}".gsub("#{Rails.root.join('public')}","")
  end
  
  def deal_with_image_entry(template,entry,image,create_or_update)
    is_create = false; is_update = false;
    if create_or_update 
      is_create = true
    else
      is_update = true
    end
    if !image.nil?
      extension = File.extname(image.original_filename).underscore
      if is_create
				    Dir.mkdir("./public/images/#{@template.id}") unless File.exist?("./public/images/#{@template.id}") 
				    Dir.mkdir("./public/images/#{@template.id}/#{@entry.id}")
      end
      store_dir = Rails.root.join("public","images","#{@template.id}","#{@entry.id}")
      timestamp = DateTime.now.strftime("%y%m%d%H%M%S") 
      store_path = "#{store_dir}/#{timestamp}#{extension}"
      File.open(store_path, "wb") do |f| 
        f.write(image.read) 
      end
      if is_update
        File.delete("#{@entry.default_value}") if File.file?("#{@entry.default_value}")
      end
      @entry.default_value = "#{store_path}"
      return true
     else
      return false
    end
  end
  
  def auto_create_email_template
    File.open(Rails.root.join("lib/emails","#{@template.file_name}.html.erb"),"w") do |file|
      str = "<h1>$|Title|$</h1>\n"
      str << "Hello $|NAME|$, Your Email is $|EMAIL|$, Subject is $|SUBJECT|$\n\n\n"
      str << "<ul>\n"
      @template.entries.each do |entry|
        if is_img_entry(entry)
          str << "<li><img src='$|#{entry.default_value}|$' alt='from @Infocus' width='150' />$|#{entry.name}|$</li>\n"
        else
          str << "<li><a href='$|#{entry.default_value}|$' target='blank'>$|#{entry.name}|$</a></li>\n"
        end
      end
      str << "</ul>\n\n\n\n\n"
      str << "@Intfocus"
      file.write(str)
      file.close
    end
  end
  
  def is_dir_empty(dir)
    Dir.foreach(Rails.root.join("public/images","#{dir}")) do |d|
      if d!="." and d!=".."
        return false 
      end
    end
    return true
  end
  def auto_check_template_img_dir
    Dir.foreach(Rails.root.join("public/images")) do |dir|
       if dir!="." and dir!=".." and Template.find_by_id(dir.to_i).nil? or is_dir_empty(dir)
         Dir.rmdir(Rails.root.join("public/images","#{dir}"))
       end
    end
  end
  
end
