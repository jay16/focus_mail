module FocusMail
  module CreateUserorg
    def self.create_userorg(user_name, user_id)
      userorg = UserOrg.create({
        :name => user_name,
        :user_id => user_id
      })
      return userorg
    end
    
    def self.create_userorg_object(user_id, userorg_id, asset_type)
      UserOrgObject.create({
        :asset_id => user_id, 
        :asset_type => asset_type, 
        :user_org_id => userorg_id
      })
    end
    
    def self.delete_userorg_object(asset_id, asset_type)
      UserOrgObject.delete_all(["asset_id = :aid and asset_type = :atype", {:aid => asset_id, :atype => asset_type}])
    end
  end
end