class Member < ActiveRecord::Base
  after_save :lists_members
  attr_accessible :email, :name, :listid, :week_number, :type_email
  has_and_belongs_to_many :list
  has_many :campaign_members

  def self.get_field_array
    # every element consist of "name", "label", "name" is column name, "label" is display name
    field_array = [["name","name"], ["email","email"]]
  end
  
  def listid
    @listid
  end
  
  def listid= (val)
    @listid = val
  end
  
  #def weeknumber
  #  @weeknumber
  #end
  #
  #def weeknumber= (val)
  #  @weeknumber = val
  #end
  
  def lists_members
    @id = Member.where(["email = :e", { :e => self.email }]).first.id
    listsmembers = ListsMembers.where(["list_id = :l and member_id = :m", { :l => self.listid, :m => @id }])
    if listsmembers.count == 0 then
      ListsMembers.create({
        :list_id => self.listid, 
        :member_id => @id
      })
    elsif listsmembers.count == 1
      ListsMembers.update(listsmembers.first.id,{ 
        :list_id => self.listid, 
        :member_id => @id
      })
    end
  end
end
