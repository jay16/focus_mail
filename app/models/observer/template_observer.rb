class TemplateObserver < ActiveRecord::Observer
  observe :template
  def after_create(item)
    FocusMail::CreateUserorg::create_userorg_object(item.id, item.org_id, "Template")
  end
  
  def after_destroy(item)
    FocusMail::CreateUserorg::delete_userorg_object(item.id, "Template")
  end
end