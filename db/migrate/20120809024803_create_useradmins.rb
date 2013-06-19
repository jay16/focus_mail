class CreateUseradmins < ActiveRecord::Migration
  def change
    create_table :useradmins do |t|
      t.integer :type_user                                        #用户权限状态
      t.integer :asset_id                                         #用户ID
      t.string :asset_type                                        #控制器名称
      
      t.timestamps
    end
  end
end
