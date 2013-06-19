class List < ActiveRecord::Base
  attr_accessible :name, :org_id, :is_used
  #has_many :members
  has_and_belongs_to_many :members

  def org_id
    return @orgid
  end
  
  def org_id= (val)
    @orgid = val
  end
end
