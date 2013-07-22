class CreateFocusServers < ActiveRecord::Migration
  def change
    create_table :focus_servers do |t|
      t.integer :campaign_id
      t.string :send_type
      t.string :file_name
      t.integer :stage
      t.string :info

      t.timestamps
    end
  end
end
