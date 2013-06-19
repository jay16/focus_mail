class UseradminObserver < ActiveRecord::Observer
  observe :useradmin
  #def after_create(item)
  #  FocusMail::CreateUserorg::create_userorg_object(item.id, item.org_id, "User")
  #end
  
  #def after_destroy(item)
  #  FocusMail::CreateUserorg::delete_userorg_object(item.id, "User")
  #end
end