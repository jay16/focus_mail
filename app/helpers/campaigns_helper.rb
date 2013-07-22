module CampaignsHelper
  def is_super
    FocusMail::UserAdmin.is_super(current_user.id)
  end
end
