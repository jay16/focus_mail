class CreateMemberOrgObjects < ActiveRecord::Migration
  def change
    create_table :member_org_objects do |t|
      t.integer :member_org_id
      t.integer :list_member_id

      t.timestamps
    end
  end
end
