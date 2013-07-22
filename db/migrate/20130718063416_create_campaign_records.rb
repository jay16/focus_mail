class CreateCampaignRecords < ActiveRecord::Migration
  def change
    create_table :campaign_records do |t|
      t.integer :focus_server_id
      t.integer :index
      t.integer :stage
      t.text :info_json

      t.timestamps
    end
  end
end
