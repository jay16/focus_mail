#encoding: utf-8
class ReportController < ApplicationController

#活动分析报表
  def campaign
    @campaign_id=params[:id]
    @campaign_name = Campaign.find(@campaign_id).name
    #总名单人数
    @total_members = CampaignList.find(:all,
                     :select => "count(distinct members.id) AS MemberCount",
                     :joins => "LEFT JOIN members ON campaign_lists.list_id = members.list_id",
                     :conditions => ["campaign_lists.campaign_id = ?", @campaign_id])
    #总打开人数       
    @total_tracks = Track.find(:all,
                     :select => "count(distinct tracks.member_id) AS MemberCount",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])
    #总点击人数
    @total_clickers = Click.find(:all,
                     :select => "count(distinct clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])
    #总点击次数
    @total_clicks = Click.find(:all,
                     :select => "count(clicks.member_id) AS MemberCount",
                     :conditions => ["clicks.campaign_id = ?", @campaign_id])
         
    @first = Track.find(:all,
                     :select => "min(tracks.created_at) AS FirstCreate",
                     :conditions => ["tracks.campaign_id = ?", @campaign_id])[0].FirstCreate
    @end = @first + 30
    
    @responsed = DimDate.find(:all,
      :select => "date_d,count(tracks.id) AS TrackNum,count(clicks.id) AS ClickNum",
      :joins => "LEFT JOIN tracks ON date(tracks.created_at) = date(dim_dates.date_d) LEFT JOIN clicks ON date(clicks.created_at) = date(dim_dates.date_d)",
      :conditions => ["date(date_d) >= date('#{@first}') and date(date_d) <= date('#{@end}')"],            
      :group => "date_d")
    #and tracks.campaign_id = #{@campaign_id}
    #and clicks.campaign_id = #{@campaign_id}
    @rule = Array.new
    @responsed.each do |m|
      @rule.push([m.date_d.strftime("%Y-%m-%d"),m.TrackNum.to_i,m.ClickNum])
    end
    
    mydata = ReportData2.new(@rule)
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
      f.series(:name => 'Clicks', :data=> mydata.get_y1 )
      f.series(:name => 'Tracks', :data=> mydata.get_y2 )
      #f.options[:chart][:inverted] = false
      #f.options[:chart][:width] = 300
      #f.options[:chart][:height] = 180
      f.options[:title][:text] = '近30天提到次数趋势'      
      f.options[:xAxis][:categories] = mydata.get_report_xAxis
      #legend 样式
      f.options[:legend][:layout] = 'horizontal' #'vertical'
      #f.options[:legend][:backgroundColor] = '#ffffff'
      #f.options[:legend][:align] = 'left'
      #f.options[:legend][:verticalAlign] = 'top'
      #f.options[:legend][:floating] = false
      #f.options[:legend][:x] = 35
      #f.options[:legend][:y] = 5
    end 
  end  
end
#
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

