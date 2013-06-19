class UserObserver < ActiveRecord::Observer
  observe :user
  def after_create(item)
    if item.email.split("@")[0].downcase == "admin" then
      create_useradmin(item.id, 1)
    else
      create_useradmin(item.id, 0)
    end
    userorgs = UserOrg.find(:all,:conditions => "name='#{item.user_org}'")
    if userorgs.count == 0 then
      userorg = FocusMail::CreateUserorg::create_userorg(item.user_org, item.id)
      FocusMail::CreateUserorg::create_userorg_object(item.id, userorg.id, "User")
      #userorg = create_userorg(item.user_org, item.id)
      #create_userorg_object(item.id, userorg.id)
    else
      FocusMail::CreateUserorg::create_userorg_object(item.id, userorgs[0].id, "User")
    end
  end
  
  def create_useradmin(user_id, type_user)
    asset_type = %w{ Templates Campaigns Reports Categories Supers }
    asset_type.each do |assettype|
      Useradmin.create({
        :type_user => type_user,
        :asset_id => user_id,
        :asset_type => assettype
      })
    end
  end
  
end
