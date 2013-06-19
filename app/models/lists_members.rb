class ListsMembers < ActiveRecord::Base
  attr_accessible :list_id, :member_id, :week_number, :domain

  def domain= (val)
    @domain = val
  end
  
  def domain
    @domain
  end
end
