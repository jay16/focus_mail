class CreateUserOrgs < ActiveRecord::Migration
  def change
    create_table :user_orgs do |t|
      t.string :name                                  #组名称
      t.integer :user_id                              #用户ID

      t.timestamps
    end
  end
end
