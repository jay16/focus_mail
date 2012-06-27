class TemplatesController < ApplicationController
  after_filter :check_email_file, :only => [:create, :update]

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
  
  def check_email_file
				Dir.foreach(Rails.root.join("lib/emails")) do |d|
				  if d!="." and d!=".." and Template.find_by_file_name(File.basename(d,".html.erb")).nil?
				    File.delete("#{email_dir}/#{d}") if File.file?("#{email_dir}/#{d}")
				  end
		  end
  end
end
