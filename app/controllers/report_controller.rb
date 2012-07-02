#encoding: utf-8
class ReportController < ApplicationController

#活动分析报表
  def campaign
    @campaign_id = params[:id]
    @campaign_name = Campaign.find(@campaign_id).name 
    @first = Track.find(:all,
                     :select => "min(tracks.created_at) AS FirstCreate",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])[0].FirstCreate
    @end = @first + 30
    @responsed = DimDate.find(:all,
      :select => "date_d,count(tracks.id) AS TrackNum,count(clicks.id) AS ClickNum",
      :joins => "LEFT JOIN tracks ON date(tracks.created_at) = date(dim_dates.date_d) LEFT JOIN clicks ON date(clicks.created_at) = date(dim_dates.date_d)",
      :conditions => ["tracks.campaign_id = ? and clicks.campaign_id = ?", @campaign_id, @campaign_id],  
      :group => "date_d")
    #["tracks.campaign_id = ? and clicks.campaign_id = ?", @campaign_id, @campaign_id],            
    #["date(date_d) >= date('#{@first}') and date(date_d) <= date('#{@end}')"]
    #and tracks.campaign_id = #{@campaign_id}
    #and clicks.campaign_id = #{@campaign_id}
    @rule = Array.new
    @responsed.each do |m|
      @rule.push([m.date_d.strftime("%Y-%m-%d"),m.TrackNum.to_i,m.ClickNum])
    end
    
    @mydata = ReportData2.new(@rule)
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
      f.series(:name => 'Clicks', :data=> @mydata.get_y1 )
      f.series(:name => 'Tracks', :data=> @mydata.get_y2 )
      f.options[:title][:text] = '近30天提到次数趋势'      
      f.options[:xAxis][:categories] = @mydata.get_report_xAxis
      f.options[:legend][:layout] = 'horizontal' #'vertical'
    end 
    
				respond_to do |format|
				  format.js
				end
  end

#点击分析报表
  def click
				@id_array = Click.find(:all,:select => "DISTINCT clicks.campaign_id AS CampaignId")
				@report_click = Array.new
				@id_array.each { |id| @report_click.push(get_report_array(id.CampaignId)) }
     
    @first = Track.find(:all,
                     :select => "min(tracks.created_at) AS FirstCreate",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])[0].FirstCreate
    @end = @first + 30
    @responsed = DimDate.find(:all,
      :select => "date_d,count(clicks.id) AS ClickNum",
      :joins => "LEFT JOIN clicks ON date(clicks.created_at) = date(dim_dates.date_d)",
      :conditions => ["clicks.campaign_id = ?", @id_array[0].CampaignId],            
      :group => "date_d")
      
    @rule = Array.new
    @responsed.each do |m|
      @rule.push([m.date_d.strftime('%Y-%m-%d'),m.ClickNum])
    end
    
    data_click = Array.new
    data_x = Array.new
    @rule.each do |rule|
      data_x.push(rule[0])
      data_click.push(rule[1])
    end
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
				    f.series(:name => 'Clicks', :data=> data_click )
      f.options[:title][:text] = '近30天提到次数趋势'      
      f.options[:xAxis][:categories] = data_x
      f.options[:legend][:layout] = 'horizontal' #'vertical'
    end 
     
				respond_to do |format|
				  format.js
				end
		end
		
		def track
				@id_array = Track.find(:all,:select => "DISTINCT tracks.campaign_id AS CampaignId")
				@report_track = Array.new
				@id_array.each { |id| @report_track.push(get_report_array(id.CampaignId)) }
     
    @responsed = DimDate.find(:all,
      :select => "date_d,count(tracks.id) AS ClickNum",
      :joins => "LEFT JOIN tracks ON date(tracks.created_at) = date(dim_dates.date_d)",
      :conditions => ["tracks.campaign_id = ?", @campaign_id],            
      :group => "date_d")
      
    @rule = Array.new
    @responsed.each do |m|
      @rule.push([m.date_d.strftime('%Y-%m-%d'),m.ClickNum])
    end
    
    data_track = Array.new
    data_x = Array.new
    @rule.each do |rule|
      data_x.push(rule[0])
      data_track.push(rule[1])
    end
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
				    f.series(:name => 'tracks', :data=> data_track )
      f.options[:title][:text] = '近30天提到次数趋势'      
      f.options[:xAxis][:categories] = data_x
      f.options[:legend][:layout] = 'horizontal' #'vertical'
    end 
     
				respond_to do |format|
				  format.js
				end
		end
end

def get_report_array(id)
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
#
class ReportData3
  @y = Array.new
  @xAxis = Array.new
  def initialize(data_from,count)
    y = Array.new
    xAxis = Array.new
    
    data_from.each do |y|
      xAxis.push(y[0])
      temp = Array.new
      (1..count-1).each { |i|  temp.push(y[i]) }
      y.push(temp)
    end
    @y=y
    @xAxis=xAxis
  end
  def get_y
    return @y
  end
  def get_report_xAxis
    return @xAxis
  end
end

class ReportData2
  @y1 = Array.new
  @xAxis = Array.new
  @y2 = Array.new
  def initialize(data_from)
    y1 = Array.new
    xAxis = Array.new
    y2 = Array.new
    
    data_from.each do |y|
      y1.push(y[1])
      y2.push(y[2])
      xAxis.push(y[0])
    end
    @y1=y1
    @y2=y2
    @xAxis=xAxis
  end
  def get_y1
    return @y1
  end
  def get_y2
    return @y2
  end
  def get_report_xAxis
    return @xAxis
  end
end

