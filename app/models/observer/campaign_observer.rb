class CampaignObserver < ActiveRecord::Observer
  observe :campaign
  def after_create(item)
    FocusMail::CreateUserorg::create_userorg_object(item.id, item.org_id, "Campaign")
  end
  
  def after_destroy(item)
    FocusMail::CreateUserorg::delete_userorg_object(item.id, "Campaign")
  end
end