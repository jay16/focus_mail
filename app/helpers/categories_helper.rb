module CategoriesHelper
  def memberorg(listid)
    mo = []
    lma = Array.new
    lms = ListsMembers.where(["list_id = :lid", :lid => listid]).all
    if lms.count > 0 then
      lms.each do |lm|
        lma.push(lm.id)
      end
    end
    moo = 0
    if lma.count > 0 then
      lma = lma.join(",")
      moos = MemberOrgObject.find(:all, :select => "max(member_org_id) as org_id", :conditions => "list_member_id in(#{lma})", :group => "member_org_id")
      mooa = Array.new
      if moos.count > 0 then
        moos.each do |moot|
          mooa.push(moot.org_id)
        end
        mooa = mooa.join(",")
      end
      if mooa.length > 0 then
        mo = MemberOrg.where(["id in (#{mooa})"]).all
      end
    end
    
    name_num = Array.new
    mo.each do |m|
      name_num.push(Org_Name_Num.new(m.name,m.member_org_object.where("list_member_id in (#{lma})").count))
    end
    name_num = name_num.sort!{|a,b| b.org_number <=> a.org_number }
    return mo,lma,name_num
  end
  
  class Org_Name_Num
    def initialize(name, number)
      @org_name = name
      @org_number = number
    end
    attr_accessor :org_name, :org_number
  end
end
