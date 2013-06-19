class CreateListsMembers < ActiveRecord::Migration
  def change
    create_table :lists_members do |t|
      t.integer :list_id
      t.integer :member_id

      t.timestamps
    end
  end
end
