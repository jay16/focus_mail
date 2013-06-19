class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, :user_right, :user_permission, :user_action_org, :except=>[:check_userorg]
  
#  rescue_from Exception do |exception|
#    render :inline => exception.to_s, :type => "html"
#  end
  
  def user_right
    if user_signed_in?
      #puts useradmin.user_id
      ctrlweb = params[:controller].downcase
      useradmin  = Useradmin.where("asset_id = #{current_user.id} and asset_type = '#{ctrlweb.capitalize}'").first
      case ctrlweb
      when "templates"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      when "campaigns"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      when "reports"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      when "categories"
        if useradmin.type_user != 1 then
          redirect_to :controller => 'home'
        end
      end
    end
  end
  
  def user_permission
    if user_signed_in?
      #useradmin  = Useradmin.where("asset_id = #{current_user.id} and asset_type = 'Supers'").first
      #if useradmin.type_user == 1 || current_user.email.split("@")[0].downcase == "admin" then
      #  @super = 1
      #else
      #  @super = 0
      #end
      useradmins  = Useradmin.where("asset_id = #{current_user.id}")
      @FocusMail = Hash.new
      useradmins.each do |admin|
        @FocusMail[admin.asset_type] = admin.type_user
      end
      @FocusMail["Supers"] = 1 if current_user.email.split("@")[0].downcase == "admin"
      @FocusMail["Delete"] = 0
      @FocusMail["Delete"] = 1 if current_user.email == "admin@intfocus.com"
    end
  end
  def user_action_log(assetid,assettype,actionname)
    assetid = assetid
    assettype = assettype
    actionname = actionname
    userid = current_user.id
    FocusMail::ClickLog.save_log(assetid, assettype, actionname, userid)
  end

  def user_action_org
    if user_signed_in?
      user_type = false
      user_id = current_user.id
      org_name = UserOrgObject.where(["asset_id = :u_id and asset_type = 'User'", {:u_id => user_id}]).last.user_org.name
      if org_name == "super" then
        user_type = true
      end
      return user_type
    end
  end

  def check_userorg
    user_org = params[:user_org]
    @user_org = UserOrg.find_by_name(user_org)
    
    respond_to do |format|
      format.js
    end
  end

end
