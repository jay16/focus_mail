class CreateUserOrgObjects < ActiveRecord::Migration
  def change
    create_table :user_org_objects do |t|
      t.integer :user_org_id
      t.integer :asset_id
      t.string :asset_type

      t.timestamps
    end
  end
end
