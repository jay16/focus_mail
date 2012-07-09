class TemplatesController < ApplicationController
  after_filter :auto_check_email_file, :only => [:create, :update, :destroy]
  after_filter :auto_check_template_img_dir, :only => [:destroy]
  after_filter :auto_create_email_template, :only => [:create]

  def index
    @templates = Template.all
    @template = Template.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @templates }
    end
  end

  def show
    @template = Template.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @template }
    end
  end

  def new
    @template = Template.new
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @template = Template.find(params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @template = Template.new(params[:template])

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: 'Template was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.js { render action: "new" }
      end
    end
  end

  def update
    @template = Template.find(params[:id])

    respond_to do |format|
      if @template.update_attributes(params[:template])
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  def destroy
    @template = Template.find(params[:id])
    @template.destroy

    respond_to do |format|
      format.html { redirect_to templates_url }
      format.js
    end
  end
  
  def dyna_source
    @template = Template.find(params[:id])
    @dyna_content = IO.readlines(Rails.root.join("lib/emails", "#{@template.file_name}.html.erb")).join("").strip
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
    def update_source
    @template = Template.find(params[:id])
    source = IO.readlines(Rails.root.join('lib/emails', "#{@template.file_name}.html.erb")).join("").strip
		  str = "ul do\n"
	   @template.entries.each do |entry|
	     if entry.default_value.present?&&File.file?("#{entry.default_value}")
	       path = "#{entry.default_value}".gsub("#{Rails.root.join('public')}","")
	       str << %{      li '<img src="#{path}" alt="#{entry.name}" width="150" />'}
	       str << "\n"
	     else
	       str << %{      li '<a href="#{entry.default_value}" target="blank">#{entry.name}</a>'}
	       str << "\n"
	     end
	   end
			 str << "    end"
			 update_source = source.gsub(/ul.*?end/m, str)
				File.open(Rails.root.join("lib/emails","#{@template.file_name}.html.erb"),"w") do |file|
		     file.write(update_source)
		     file.close
		  end
		  @dyna_content = update_source
		  
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def auto_check_email_file
				Dir.foreach(Rails.root.join("lib/emails")) do |d|
				  if d!="." and d!=".." and Template.find_by_file_name(File.basename(d,".html.erb")).nil?
				    File.delete("#{Rails.root.join("lib/emails")}/#{d}") if File.file?("#{Rails.root.join("lib/emails")}/#{d}")
				  end
		  end
  end
  
  def is_dir_empty(dir)
    Dir.foreach(Rails.root.join("public/entries","#{dir}")) do |d|
      if d!="." and d!=".."
        return false 
      end
    end
    return true
  end
  def auto_check_template_img_dir
    img_dir = Rails.root.join("public/entries")
    Dir.foreach(img_dir) do |dir|
       if dir!="." and dir!=".." and Template.find_by_id(dir.to_i).nil?
         FileUtils.remove_dir("#{img_dir}/#{dir}") if File.exists?("#{img_dir}/#{dir}")
       end
    end
  end
  
  def auto_create_email_template
    @template = Template.new(params[:template])
		  File.open(Rails.root.join("lib/emails","#{@template.file_name}.html.erb"),"w") do |file|
		     str = "Markaby::Builder.new.html do\n"
		     str << "  head do\n"
		     str << '    title "$|Title|$"'
		     str << "\n  end\n"
		     str << "  body do\n"
		     str << '    p "Hello $|NAME|$, Your Email is $|EMAIL|$, Subject is $|SUBJECT|$"'
		     str << "\n    ul do\n"
		     unless @template.entries.empty?
						   @template.entries.each do |entry|
						     if is_img_entry(entry)
						       path = img_path(entry)
						       str << %{      li '<img src="#{path}" alt="#{entry.name}" width="150" />'}
						       str << "\n"
						     else
						       str << %{      li '<a href="#{entry.default_value}" target="blank">#{entry.name}</a>'}
						       str << "\n"
						     end
						   end
						 end
						 str << "    end\n"
						 str << "  end\n"
						 str << "end\n"
		     file.write(str)
		     file.close
		  end
  end
end
