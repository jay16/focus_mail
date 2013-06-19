class ListsController < ApplicationController
  # GET /lists
  # GET /lists.json
  def index
   # @lists = List.all
   # @list = List.new
    user_id = current_user.id
    #userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @lists = List.where(:is_used => true)
    else
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
      @lists = List.find(orglist).where(:is_used => true)
    end
    @list = List.new
    user_action_log(0,params[:controller],"index")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lists }
    end
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
    redirect_to list_members_path(params[:id])
    user_action_log(params[:id],params[:controller],"show")
  end

  # GET /lists/new
  # GET /lists/new.json
  def new
    #@list = List.new
    user_id = current_user.id
    @list = List.new
    @list.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id])
    user_action_log(params[:id],params[:controller],"edit")

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /lists
  # POST /lists.json
  def create
    @list = List.new(params[:list])
    #is_used表示该名单列表在使用中
    @list.is_used = true

    respond_to do |format|
      if @list.save
        user_action_log(@list.id,params[:controller],"create")
        format.html { redirect_to @list, notice: 'List was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.js { render action: "new" }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.json
  def update
    @list = List.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        user_action_log(params[:id],params[:controller],"update")
        format.html { redirect_to @list, notice: 'List was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list = List.find(params[:id])
    @list.update_attribute(:is_used,false)
    puts "*"*100
    puts "lists_controlle"
    #没有物理删除名单列表，可以恢复
    #@list.destroy
    user_action_log(params[:id],params[:controller],"delete")

    respond_to do |format|
      format.html { redirect_to lists_url }
      format.js
    end
  end
end
