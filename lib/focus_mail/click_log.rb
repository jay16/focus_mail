module FocusMail
  module ClickLog
    def self.save_log(assetid, assettype, actionname, userid)
      ActionLog.create({
        :action_datetime => Time.now(), 
        :action_name => actionname, 
        :asset_id => assetid, 
        :asset_type => assettype, 
        :user_id => userid
      })
    end
  end
end