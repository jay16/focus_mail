require 'will_paginate/array'
class UseradminsController < ApplicationController
  # GET /Useradmins
  # GET /Useradmins.json
  def index
    #@useradmins = Useradmin.find(:all, :select => "max(asset_id) as user_id, asset_id", :group => "asset_id")
    #@useradmin = Useradmin.new
    @superuser = false
    user_id = current_user.id
    controller = "User"
    orglist = FocusMail::ListUserorg::userorg_list(user_id, controller)
    if orglist.count != 0 then
      orglist = orglist.join(",")
      condition = "asset_id in (#{orglist})"
    else
      condition = "1=0"
    end
    #userids = [1,2,3,4,5,6,7,8,9,10]
    if user_action_org then
      condition = "1=1"
      @superuser = true
    end
    @useradmins = Useradmin.find(:all, :select => "max(asset_id) as user_id, asset_id", :conditions => condition, :group => "asset_id")
    .paginate(:page => params[:page], :per_page => 13)
    @useradmin = Useradmin.new
    user_action_log(0,params[:controller],"index")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @useradmins }
    end
  end

  def saveuser
    email_name = params[:uemail]
    user_id = current_user.id
    userorg = UserOrg.where(["user_id = :uid", {:uid => user_id}]).all
    if userorg.count > 0 then
      orgid = userorg.first.id
    else
      moo = MemberOrgObject.where(["asset_id = :uid and asset_type = 'User'", {:uid => user_id}]).first
      orgid = moo.id
    end
    user_org = UserOrg.find(orgid)
    u = User.new({
      :email => email_name, 
      :password => email_name, 
      :password_confirmation => email_name, 
      :user_org => user_org.name
      })
    u.save
    @user = User.find(user_id) 
    @useradmins = Useradmin.find(:all, :select => "max(asset_id) as user_id, asset_id", :group => "asset_id", :conditions => "asset_id = #{user_id}")
    user_action_log(params[:id],params[:controller],"saveuser")
  end

  # GET /Useradmins/1
  # GET /Useradmins/1.json
  def show
    redirect_to useradmin_members_path(params[:id])
    user_action_log(params[:id],params[:controller],"show")
  end

  # GET /Useradmins/new
  # GET /Useradmins/new.json
  def new
    @useradmin = Useradmin.new
    @user = User.new
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /Useradmins/1/edit
  def edit
    @user = User.find(params[:id])
    @useradmin = Useradmin.where("asset_id = #{params[:id]}")
    user_action_log(params[:id],params[:controller],"edit")

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /Useradmins
  # POST /Useradmins.json
  def create
    @useradmin = Useradmin.new(params[:useradmin])

    respond_to do |format|
      @useradmin.user_id = params[:user_id]
      if @useradmin.save
        user_action_log(@useradmin.id,params[:controller],"create")
        format.html { redirect_to @useradmin, notice: 'Useradmin was successfully created.' }
        format.js
      else
        format.html { render action: "new" }
        format.js { render action: "new" }
      end
    end
  end

  # PUT /Useradmins/1
  # PUT /Useradmins/1.json
  def update
    @useradmin = Useradmin.find(params[:id])
    #
    respond_to do |format|
      if @useradmin.update_attributes(params[:useradmin])
        user_action_log(params[:id],params[:controller],"update")
        format.html { redirect_to @useradmin, notice: 'Useradmin was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js { render action: "edit" }
      end
    end
  end

  # DELETE /Useradmins/1
  # DELETE /Useradmins/1.json
  def destroy
   # @useradmin = Useradmin.find(:all, :condiction => "asset_id = #{params[:id]}")
   # @useradmin.destroy
   user_id = params[:id]
    Useradmin.delete_all(["asset_id = :aid", {:aid => user_id}])
    User.delete(user_id)
    FocusMail::CreateUserorg::delete_userorg_object(user_id, "User")
    
    @useradmin = user_id
    user_action_log(params[:id],params[:controller],"delete")

    respond_to do |format|
      format.html { redirect_to useradmins_url }
      format.js
    end
  end
  
  def saveupdate
    user_id = params[:userid]
    templates = params[:templates]
    campaigns = params[:campaigns]
    reports = params[:reports]
    categories = params[:categories]
    supers = params[:supers]
    user_update(user_id, "Templates", templates)
    user_update(user_id, "Campaigns", campaigns)
    user_update(user_id, "Reports", reports)
    user_update(user_id, "Categories", categories)
    user_update(user_id, "Supers", supers)
    @user = User.find(user_id) 
    @useradmins = Useradmin.find(:all, :select => "max(asset_id) as user_id, asset_id", :group => "asset_id", :conditions => "asset_id = #{user_id}")
    user_action_log(user_id,params[:controller],"saveupdate")
  end
  
  def user_update(asset_id, asset_type, type_user)
    useradmin = Useradmin.where("asset_id = #{asset_id} and asset_type = '#{asset_type}'").first
    useradmin.update_attributes(:type_user => type_user.to_i)
  end
end
