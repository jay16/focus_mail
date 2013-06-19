class CreateActionLogs < ActiveRecord::Migration
  def change
    create_table :action_logs do |t|
      t.string :action_name                                  #点击动作名称
      t.integer :user_id                                     #点击用户ID
      t.datetime :action_datetime                            #点击动作时间
      t.integer :asset_id                                    #被点击动作ID
      t.string :asset_type                                   #控制器名称

      t.timestamps
    end
  end
end
