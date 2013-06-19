class ListMemberObserver < ActiveRecord::Observer
  observe :lists_members
  def after_create(item)
    memberorg = MemberOrg.find(:all, :conditions => "name = '#{item.domain}'")
    if memberorg.count <= 0 then
      memberorg = MemberOrg.create({
        :name => item.domain
      })
    else
      memberorg = memberorg.first
    end
    MemberOrgObject.create({
      :list_member_id => item.id, 
      :member_org_id => memberorg.id
    })
  end
  
  def after_destroy(item)
  end
end