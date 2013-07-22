module FocusMail
  module UserAdmin
    def self.is_super(assetid)
      user = Useradmin.where(["asset_id = :uid and asset_type = 'Supers'", {:uid => assetid}]).first

      return user.type_user
    end
  end
    
end