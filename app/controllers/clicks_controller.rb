class ClicksController < ApplicationController
  layout "appclickinfo"
  require 'will_paginate/array'
  
  def index
   if params[:l_id].present? and params[:c_id].present?
     @clicks = Click.includes(:member, :campaign, :link).paginate(:page => params[:page], :per_page => 20 ,:conditions  => ["link_id = ? and campaign_id = ?", params[:l_id],params[:c_id]])
   elsif params[:c_id].present?
     #@clicks = Click.includes(:member, :campaign, :link).order("member_id desc").paginate(:page => params[:page], :per_page => 20 ,:conditions  => ["campaign_id = ?", params[:c_id]])
     @clicks = Click.includes(:member, :campaign, :link)
                    .select("member_id,campaign_id,link_id,count(*) as count,max(updated_at) as last_at")
                    .group("member_id,link_id")
                    .order("max(updated_at) desc")
                    .where("campaign_id=?",params[:c_id])
                    .paginate(:page => params[:page],:per_page => 20, :order => "last_at desc")
                    
      @click_data = Click.select("count(member_id) as click_num,count(distinct member_id) as peo_num").where("campaign_id = ?",params[:c_id])[0]
   else
     @clicks = Click.includes(:member, :campaign, :link)
                    .select("member_id,campaign_id,link_id,count(*) as count,max(updated_at) as last_at")
                    .group("member_id,link_id")
                    .order("max(updated_at) desc")
                    .paginate(:page => params[:page],:per_page => 20, :order => "last_at desc")
                    
     @click_data = Click.select("count(member_id) as click_num,count(distinct member_id) as peo_num")[0]
   end
    
    user_action_log(0,params[:controller],"index")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clicks }
    end
  end
  
  def detail
    @clicks = Click.includes(:member,:campaign,:link).paginate(:conditions => ["campaign_id = ? and link_id = ?", params[:c_id],params[:l_id]],:page => params[:page], :per_page => 20)
    user_action_log(0,params[:controller],"detail")
  end
  
end
