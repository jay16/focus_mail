class CreateMemberOrgs < ActiveRecord::Migration
  def change
    create_table :member_orgs do |t|
      t.string :name

      t.timestamps
    end
  end
end
