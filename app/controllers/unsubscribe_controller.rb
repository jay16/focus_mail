#encoding: utf-8
class UnsubscribeController < ActionController::Base
  include ApplicationHelper
  before_filter :configure_charsets  
  
  def configure_charsets  
    #@response.headers["Content-Type"] = "text/html; charset=utf-8"  
    suppress(ActiveRecord::StatementInvalid) do  
        ActiveRecord::Base.connection.execute 'SET NAMES utf8'  
    end  
  end  
    
  def ganso
    campaign_id  = params[:cid]
    email       = params[:email]
    
    if campaign_id and email then
    #用户是否已经取消请阅
    @count = Unsubscribe.select("count(email) as count")
            .order("created_at desc")
            .where("campaign_id=#{campaign_id} and email='#{email}'")[0].count
    else
     @count = nil
    end

  end
  
  def missario
    campaign_id  = params[:cid]
    email       = params[:email]
    
    if campaign_id and email then
    #用户是否已经取消请阅
    @count = Unsubscribe.select("count(email) as count")
            .order("created_at desc")
            .where("campaign_id=#{campaign_id} and email='#{email}'")[0].count
    else
     @count = nil
    end

  end
  
  def create
    cid   = params[:campaign_id]
    email = params[:email]
    reason = params[:reason]
    
#   sql = "INSERT INTO unsubscribes (campaign_id, created_at, email, reason) "
#   sql << " VALUES  ("+campaign_id.to_s
#   sql << ", '"+(Time.now+28800).to_s
#   sql << "', '"+email.to_s+"',' "+reason.to_s+"')"
    
   # ActiveRecord::Base.connection.execute(sql)
    Unsubscribe.create({
       :email       => email,
       :campaign_id => cid,
       :reason =>  reason,
       :created_at => Time.now+28800
      })
  
     render :text => "UnSubscribe Successfully!"
  end

end
