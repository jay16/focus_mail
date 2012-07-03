class TracksController < ApplicationController
  def index
    @tracks = Track.includes(:member, :campaign).paginate(:page => params[:page], :per_page => 10)
    
    @campaign_id_array = Track.find(:all,
      :select => "DISTINCT campaign_id AS CampaignId,campaigns.name AS CampaignName",
      :joins =>"LEFT JOIN campaigns ON campaigns.id = tracks.campaign_id")
      
    @campaign_track_report = Array.new
    @campaign_id_array.each do |campaign|
				  track_report = Track.find(:all,
				    :select => "COUNT(DISTINCT tracks.member_id) AS TrackNumber,COUNT(tracks.member_id) AS TotalNumber",
				    :conditions => ["campaign_id = #{campaign.CampaignId}"])
				    
				  total_mem = Member.find(:all,
				    :select => "COUNT(DISTINCT email) AS TotalMem",
				    :joins => "LEFT JOIN lists ON lists.id = members.list_id LEFT JOIN campaign_lists ON campaign_lists.list_id = lists.id LEFT JOIN campaigns ON campaigns.id = campaign_lists.campaign_id",
				    :conditions => ["campaign_id = #{campaign.CampaignId}"])
				  report = Array.new
				  report.push(campaign.CampaignName,total_mem[0].TotalMem,track_report[0].TrackNumber, campaign.CampaignId)
				  @campaign_track_report.push(report)
    end
				  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracks }
    end
  end
end
