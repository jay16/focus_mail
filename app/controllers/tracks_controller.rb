class TracksController < ApplicationController
  layout "appclickinfo"
  
  def index
    if params[:c_id].present?
      #@tracks = Track.includes(:member,:campaign).order("created_at desc").paginate(:conditions => ["campaign_id = ?", params[:c_id]],:page => params[:page], :per_page => 20)
      @tracks = Track.includes(:member,:campaign)
                      .select("campaign_id,member_id,count(*) as count,max(created_at) as last_at")
                      .group("member_id")
                      .where("campaign_id = ?",params[:c_id])
                      .paginate(:page => params[:page],:per_page => 20, :order => "last_at desc")
                      
      @track_data = Track.select("count(member_id) as track_num,count(distinct member_id) as peo_num").where("campaign_id = ?",params[:c_id])[0]
    else
      @tracks = Track.includes(:member,:campaign)
                      .select("campaign_id,member_id,count(*) as count,max(created_at) as last_at")
                      .group("member_id")
                      .paginate(:page => params[:page],:per_page => 20, :order => "last_at desc")
                      
      @track_data = Track.select("count(member_id) as track_num,count(distinct member_id) as peo_num")[0]      
    end     
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracks }
    end
  end
  
  def detail
    @tracks = Track.includes(:member,:campaign).order("created_at desc").paginate(:conditions => ["campaign_id = ? and member_id = ?", params[:c_id],params[:m_id]],:page => params[:page], :per_page => 20)
  end
end