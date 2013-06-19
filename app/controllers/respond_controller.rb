class RespondController < ActionController::Base
  include ApplicationHelper

  def index
    filter_time = params[:f]
    @where = ''
    @where1 = ''
    if filter_time != '' and filter_time != nil then
      case filter_time.size
        when 4 then
          @where = 'year(campaigns.created_at) = ' + filter_time.to_s
        when 6 then 
          @where = 'year(campaigns.created_at) = ' + filter_time.to_s[0..3]
          @where1 = 'month(campaigns.created_at) = ' + filter_time.to_s[4..5].to_i.to_s
      end
    end

     
    @cam_list = Campaign.find(:all,
      :conditions => ["#{@where}"],
      :conditions => ["#{@where1}"])
  end

  def dyna
      remote_ip = request.remote_ip 
      respond   = request.env["HTTP_USER_AGENT"].downcase
      keywords = %w(firefox chrome safari msie opera maxthon theworld netscape iphone ipad android)
      keynames = %w(Firefox Chrome Safari IE Opera Maxthon TheWorld Netscapt iphone ipad android)
      
      browser = "other"
      
      keywords.each do |key|
        if respond.include?(key) then
          browser = key
          break
        end
      end

    send_data open(Rails.root.join("public/browser", "#{browser}.jpg"), 'rb').read, :type => 'image/jpeg', :disposition => 'inline'
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
    cid         = params[:cid]
    email       = params[:email]
    if link_id && member_id && campaign_id
      link = Link.find(link_id)
      remote_ip = request.remote_ip
      browser   = request.env["HTTP_USER_AGENT"]
      Click.create(member_id: member_id,
                 campaign_id: campaign_id, 
                     link_id: link_id,
                   remote_ip: remote_ip,
                     browser: browser,
                  created_at: Time.now+28800,
                  updated_at: Time.now+28800)
    end
    if link_id.to_i == 197 && campaign_id.to_i == 33 then
      member = Member.find(member_id)
      #user_id = 3333
      puts "========================================="
      puts link.url.to_s + "#{member.parameter1}.html"
      puts "========================================="
      redirect_to link.url.to_s + "#{member.parameter1}.html"
    #邮件中退订邮件订阅链接，特殊处理
    elsif cid.to_i > 0 and email then
      redirect_to link.url+"?cid=#{cid}&email=#{email}"
    else
      redirect_to link.url
    end
    #redirect_to link.url
  end

  def track
    member_id = params[:u]
    campaign_id = params[:c]
    if member_id && campaign_id

      remote_ip = request.remote_ip 
      browser   = request.env["HTTP_USER_AGENT"]
      track = Track.create(member_id: member_id, 
                         campaign_id: campaign_id,
	                   remote_ip: remote_ip,
                             browser: browser,
                          created_at: Time.now+28800,
                          updated_at: Time.now+28800)
     
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
    
    @campaigns = Array.new
    @i = Array.new
    @i = [1,2,3,4,5,6]
    @i.each do |i|
      @pie = LazyHighCharts::HighChart.new('graph') do |f|
        f.chart({:plotBackgroundColor=> nil , 
          :height => 100,
          :width => 100,
          :plotShadow => false})
        f.title({:text=> ''})
        f.plotOptions({:pie=>{
            :allowPointSelect=> true , 
            :cursor=> 'pointer' , 
            :dataLabels=>{
              :enabled=> false , 
              :color=> '#000000' , 
              :connectorColor=> '#000000'}}})
        f.series({:type=>'pie' , :name=> 'Browser share' , 
            :data=> [
          ['back hard',   10.0],
          ['back soft',   13.8],
          ['Reached', 50.8],
          ['Account',    17.5]
        ]})
        f.tooltip({:enabled => false })
      end
        
      @send_totle = 50000
      @send_reach = 45000
      @back_hard = 2100
      @back_soft = 1300
      @account_erro = 1100
      @back_other = 500
      @campaign = Array.new
      @campaign.push(i,@pie,@send_totle,@send_reach,@back_hard,@back_soft,@account_erro,@back_soft,)
      
      @campaigns.push(@campaign)
    end
   
    respond_to do |format|
      format.html { render :layout => false } #:layout => false 设置不使用页面框架
      #format.json  { render :json => @home }
    end
  end
end
