class HomeController < ApplicationController
  include ApplicationHelper
  
  def test
    
  end
   
  def index
    filter_time = params[:f]
    @where = ''
    @where1 = ''
    if filter_time != '' and filter_time != nil then
      case filter_time.size
        #year
        when 4 then
          @where = 'year(campaigns.created_at) = ' + filter_time.to_s
        #year month
        when 6 then 
          @where = 'year(campaigns.created_at) = ' + filter_time.to_s[0..3]
          @where1 = 'month(campaigns.created_at) = ' + filter_time.to_s[4..5].to_i.to_s
      end
    else
      @where = "year(campaigns.created_at) =  " + Time.now.year.to_s
      @where1 = "month(campaigns.created_at) = " + Time.now.month.to_s
    end
    @where += " and #{@where1}"  if @where1.present?


    user_id = current_user.id
    @list_members = 0
    @tracks = 0
    @clicks = 0
    userids = [6,7,8,9,10,12,13]
    if user_action_org then
      @cam_list = Campaign.paginate(
        :conditions => "#{@where}",
        :order => "updated_at desc",
        :page => params[:page],
        :per_page => 6)
        
#      @cam_list.each_with_index do |cam,index|
#        if ActionLog.where("asset_id = ? and action_name = 'Deliver'",cam.id).count == 0
#          @cam_list.delete_at(index)
#        end
#      end

    else
      controller = "Campaign"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller).join(",")
      if orglist.length == 0 then
        orglist = "1=2"
        campaignid = "1=2"
      else
        orglist = "id in (#{orglist})"
        campaignid = "campaign_id in (#{orglist})"
      end
      @where += " and #{orglist}" if @where.present?
      @where += "#{orglist}" unless @where.present?
       
      @cam_list = Campaign.paginate(
        :conditions => "#{@where}",
        :order => "created_at desc",
        :page => params[:page],
        :per_page => 6)
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller).join(",")
      puts "*"*50
      puts orglist.to_s
    end  
    @member_num = 0
    @be_hits_num = 0
    @reach_num = 0
#    @cam_list.each do |cl|
#      campaign_nums = SendState.where(["campaign_id = :cid", {:cid => cl.id}]).last
#      if campaign_nums.total_address_number != nil then 
#        @member_num += campaign_nums.total_address_number.to_i
#      end
#      if campaign_nums.be_hits_number != nil then
#        @be_hits_num += campaign_nums.be_hits_number.to_i
#      end
#      if campaign_nums.reach_number != nil then
#        @reach_num += campaign_nums.reach_number.to_i
#      end
#    end 
  end

  def generate_email

  end

  def send_email
    from_name = params[:from_name]
    from_email = params[:from_email]
    from = from_name.present? ? %{"#{params[:from_name]}" <#{params[:from_email]}>} : params[:from_email]
    subject = params[:subject]
    to_email = params[:to_email]
    to_name = params[:to_name]
    to = to_name.present? ? %{"#{params[:to_name]}" <#{params[:to_email]}>} : params[:to_email]
    body = params[:body]
    amount = params[:amount] || 1

    amount.to_i.times{ FocusMailer.send_email(from, to, subject, body).deliver }
    #Resque.enqueue(EmailSender, from_name, from_email, subject, to_email, amount, body)
    redirect_to root_path, :notice => "Email is sending"
  end

  def click
    link_id = params[:l]
    member_id = params[:u]
    campaign_id = params[:c]
    if link_id && member_id && campaign_id
      link = Link.find(link_id)
      Click.create(member_id: member_id, campaign_id: campaign_id, link_id: link_id)
    end
    redirect_to link.url
  end

  def track
    member_id = params[:u]
    campaign_id = params[:c]
    if member_id && campaign_id
      Track.create(member_id: member_id, campaign_id: campaign_id)
    end
    send_data open(Rails.root.join("app/assets/images", "track.gif"), 'rb').read, :type => 'image/gif', :disposition => 'inline'
  end


  def preview
    campaign = Campaign.find(params[:campaign_id])
    member_id = 0
    source = replace_email_source(campaign.id, member_id)
    respond_to do |format|
      format.html { render :text => source, :layout => false }
    end
  end

  def campaign
    cam_id = params[:cam_id]
    @cam_list = SendState.where(["campaign_id = :cid", {:cid => cam_id}]).last
   
    respond_to do |format|
      format.html { render :layout => false } #:layout => false 设置不使用页面框架
      #format.json  { render :json => @home }
    end
  end
end
