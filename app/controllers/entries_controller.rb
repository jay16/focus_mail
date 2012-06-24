class EntriesController < ApplicationController
  
  def new
    @template = Template.find(params[:template_id])
    @entry = @template.entries.build
    params[:entry_type] = "entry_link"

    respond_to do |format|
      format.js
    end
  end
  
  def new_image
    @template = Template.find(params[:template_id])
    @entry = @template.entries.build
    params[:entry_type] = "entry_image"

    respond_to do |format|
      format.js { render "entries/new.js.erb" }
    end
  end
  

  def edit
    @template = Template.find(params[:template_id])
    @entry = @template.entries.find(params[:id])
    @is_image = is_img_entry(@entry)
    @img_path = img_path(@entry) if @is_image
    
    respond_to do |format|
      format.js
    end
  end

  def create
    @template = Template.find(params[:template_id])
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
    @template = Template.find(params[:template_id])
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
    @template = Template.find(params[:template_id])
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

  
end