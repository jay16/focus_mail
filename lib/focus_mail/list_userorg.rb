module FocusMail
  module ListUserorg
    def self.userorg_list(assetid, assettype)
      orglist = Array.new
      userorg = UserOrgObject.where(["asset_id = :uid and asset_type = 'User'", {:uid => assetid}]).first
      if userorg != nil then
        userorgs = UserOrgObject.where(["user_org_id = :uoid and asset_type = :ct ", {:uoid => userorg.user_org_id, :ct => assettype}]).all
        userorgs.each do |uo|
          orglist.push uo.asset_id
        end
      end
      return orglist
    end
    
    def self.userorg_id(assetid)
      userorg = UserOrgObject.where(["asset_id = :uid and asset_type = 'User'", {:uid => assetid}]).first
      return userorg.user_org_id
    end
    
    def self.userorg(assetid)
      user_org_object = UserOrgObject.where(["asset_id = :uid and asset_type = 'User'", {:uid => assetid}]).first
      user_org = UserOrg.find(user_org_object.user_org_id)
      return [user_org.id,user_org.name]
    end
  end
end