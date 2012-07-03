#encoding: utf-8
class ReportController < ApplicationController
  require "will_paginate/array"
  
#活动分析报表
  def campaign
    @campaign_id = params[:id]
    @campaign_report = get_campaign_report_by_id(@campaign_id)
    @campaign_name = Campaign.find(@campaign_id).name 

    @responsed1 = DimDate.find(:all,
      :select => "date_d,count(tracks.id) AS TrackNum",
      :joins => "LEFT JOIN tracks ON date(tracks.created_at) = date(dim_dates.date_d)",
      :conditions => ["tracks.campaign_id = ?", @campaign_id],  
      :group => "date_d")

    @rule1 = Array.new
    @responsed1.each do |m|
      @rule1.push([m.date_d.strftime("%Y-%m-%d"),m.TrackNum])
    end
    @responsed2 = DimDate.find(:all,
      :select => "date_d,count(clicks.id) AS ClickNum",
      :joins => "LEFT JOIN clicks ON date(clicks.created_at) = date(dim_dates.date_d)",
      :conditions => ["clicks.campaign_id = ?",@campaign_id],  
      :group => "date_d")

    @rule2 = Array.new
    @responsed2.each do |m|
      @rule2.push([m.date_d.strftime("%Y-%m-%d"),m.ClickNum])
    end
    
    @data_track = Array.new
    @data_x1 = Array.new
    @rule1.each do |r|
      @data_x1.push(r[0])
      @data_track.push(r[1])
    end
    @data_click = Array.new
    @data_x2 = Array.new
    @rule2.each do |r|
      @data_x2.push(r[0])
      @data_click.push(r[1])
    end 
    @data_x = Array.new
    @data_x =  @data_x1|@data_x2 
    
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
      f.series(:name => 'Clicks', :data=> @data_click )
      f.series(:name => 'Tracks', :data=> @data_track )
      f.options[:title][:text] = '近30天campaign分析报告'      
      f.options[:xAxis][:categories] = @data_x
      f.options[:legend][:layout] = 'horizontal' #'vertical'
    end 
    
				respond_to do |format|
				  format.js
				end
  end

#点击分析报表
  def click
    @report_click,@h = get_analyze_report("Click","clicks",params[:campaign_id])
    params[:campaign_id].present?? (@isCampare=false) : (@isCampare=true) 
    
      
				respond_to do |format|
				  format.js
				end
		end
		
		def click_list
		  @campaign_id = params[:campaign_id]
		  @clicks = Click.find(:all,
		    :select => "members.name AS MemName,members.email AS MemEmail,links.url AS LinkUrl,campaigns.name AS CampaignName",
		    :joins => "LEFT JOIN members ON members.id = clicks.member_id LEFT JOIN links ON links.id = clicks.link_id LEFT JOIN campaigns ON campaigns.id = clicks.campaign_id",
		    :conditions => ["clicks.campaign_id = ?", @campaign_id]).paginate(:page => params[:page], :per_page => 10)
		  
				respond_to do |format|
				  format.js
				end		  
		end
				
		def click_gt_two
		  @campaign_id = params[:campaign_id]
    @click_gt_2 = Click.find(:all,
				    :select => "*,COUNT(DISTINCT link_id) AS ReCount,members.name AS MemName,members.email AS MemEmail,links.url AS LinkUrl",
				    :joins => "LEFT JOIN members ON clicks.member_id = members.id LEFT JOIN links ON clicks.link_id = links.id",
				    :conditions => ["clicks.campaign_id = ?", @campaign_id],
				    :group => "member_id",
				    :having =>"COUNT(link_id) >= 2")
				@click_gt_2_count = @click_gt_2.size
				@click_gt_2 = @click_gt_2.paginate(:page => params[:page], :per_page => 10)
		 
				respond_to do |format|
				  format.js
				end
		end
#打开分析报表	
		def track
				@report_track,@h = get_analyze_report("Track","tracks",params[:campaign_id])
				params[:campaign_id].present?? (@isCampare=false) : (@isCampare=true) 
				
				respond_to do |format|
				  format.js
				end
		end
		
		def track_list
		  @campaign_id = params[:campaign_id]
		  @tracks = Track.find(:all,
		    :select => "members.name AS MemName,members.email AS MemEmail,campaigns.name AS CampaignName",
		    :joins => "LEFT JOIN members ON members.id = tracks.member_id LEFT JOIN campaigns ON campaigns.id = tracks.campaign_id",
		    :conditions => ["tracks.campaign_id = ?", @campaign_id]).paginate(:page => params[:page], :per_page => 10)
		  
				respond_to do |format|
				  format.js
				end		  
		end

end

def get_analyze_report(table,entry,campaign_id)
  @report_click = Array.new
		@data_x = Array.new
		@data_click = Array.new
  if campaign_id.nil?
    @id_array=case table
    when "Click"
      Click.find(:all,:select => "DISTINCT #{entry}.campaign_id AS CampaignId")
    when "Track" 
      Track.find(:all,:select => "DISTINCT #{entry}.campaign_id AS CampaignId")
    else          
      Click.find(:all,:select => "DISTINCT #{entry}.campaign_id AS CampaignId")
    end
    @datax = Array.new
				@id_array.each do |template_id| 
						@report_click.push(get_campaign_report_by_id(template_id.CampaignId)) 
				  responsed = DimDate.find(:all,
				    :select => "date_d,count(#{entry}.id) AS ClickNum",
				    :joins => "LEFT JOIN #{entry} ON date(#{entry}.created_at) = date(dim_dates.date_d)",
				    :conditions => ["#{entry}.campaign_id = ?", template_id.CampaignId],            
				    :group => "date_d")
				  rule = Array.new
				  responsed.each do |m|
				    rule.push([m.date_d.strftime('%Y-%m-%d'),m.ClickNum])
				  end
				  data_x = Array.new
				  data_click = Array.new
				  rule.each do |r|
				    data_x.push(r[0])
				    data_click.push(r[1])
				  end
				  @datax.push(data_x)
				  @data_click.push(data_click)
			 end
			 
			 @datax.each do |x|
			   @data_x |= x
			 end
  else
    @report_click.push(get_campaign_report_by_id(campaign_id)) 
				responsed = DimDate.find(:all,
				    :select => "date_d,count(#{entry}.id) AS ClickNum",
				    :joins => "LEFT JOIN #{entry} ON date(#{entry}.created_at) = date(dim_dates.date_d)",
				    :conditions => ["#{entry}.campaign_id = ?", campaign_id],            
				    :group => "date_d")

		  responsed.each do |m|
		    @data_x.push(m.date_d.strftime('%Y-%m-%d'))
		    @data_click.push(m.ClickNum)
		  end
  end
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
      if campaign_id.nil?
				    (0..@id_array.size-1).each do |i| 
				      f.series(:name => "template#{@id_array[i].CampaignId}", :data=> @data_click[i] )
				    end
				  else
				    f.series(:name => "#{@report_click[0][0]}", :data=> @data_click )
				  end
      f.options[:title][:text] = "近30天#{entry}分析报告"      
      f.options[:xAxis][:categories] = @data_x
      f.options[:legend][:layout] = 'horizontal' #'vertical'
    end 

    return @report_click,@h
end

def get_campaign_report_by_id(id)
    @campaign_id = id
    @campaign_name = Campaign.find(@campaign_id).name
    #总名单人数
    @total_members = CampaignList.find(:all,
                     :select => "count(distinct members.id) AS MemberCount",
                     :joins => "LEFT JOIN members ON campaign_lists.list_id = members.list_id",
                     :conditions => ["campaign_lists.campaign_id = ?", @campaign_id])[0].MemberCount
    #总打开人数       
    @total_tracks = Track.find(:all,
                     :select => "count(distinct tracks.member_id) AS MemberCount",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击人数
    @total_clickers = Click.find(:all,
                     :select => "count(distinct clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])[0].MemberCount
    #总点击次数
    @total_clicks = Click.find(:all,
                     :select => "count(clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])[0].MemberCount
                     
    @report_array = Array.new
    @report_array.push(@campaign_name,@total_members,@total_tracks,@total_clickers,@total_clicks)
    
    return @report_array
end

