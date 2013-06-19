class ListObserver < ActiveRecord::Observer
  observe :list
  def after_create(item)
    FocusMail::CreateUserorg::create_userorg_object(item.id, item.org_id, "List")
  end
  
  def after_destroy(item)
    FocusMail::CreateUserorg::delete_userorg_object(item.id, "List")
  end
end