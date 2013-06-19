class CreateSendStates < ActiveRecord::Migration
  def change
    create_table :send_states do |t|
      t.integer :total_address_number                                  #总地址数
      t.integer :effective_operand_address                             #有效地址数
      t.integer :has_sent_number                                       #已发送数
      t.float :send_ratio                                              #发送率  
      t.integer :reach_number                                          #到达数  
      t.float :reach_ratio                                             #到达率  
      t.integer :open_number                                           #打开数  
      t.float :open_ratio                                              #打开率  
      t.integer :be_hits_number                                        #被点击数
      t.float :be_hits_ratio                                           #点击率  
      t.integer :campaign_id                                           #模板id
      t.integer :track_no_click_count                                  #开信后未点击
      t.integer :click_one_count                                       #仅点击单一链接
      t.integer :click_many_count                                      #重复点击相同链接
      t.integer :click_many_counts                                     #重复点击多个链接
      t.integer :oneday                                                #一天以内
      t.integer :onedaylast                                            #一天以上
      t.integer :threedaylast                                          #三天以上
      t.integer :sevenlast                                             #一周以上

      t.timestamps
    end
  end
end
