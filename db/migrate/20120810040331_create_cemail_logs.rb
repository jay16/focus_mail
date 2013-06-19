class CreateCemailLogs < ActiveRecord::Migration
  def change
    create_table :cemail_logs do |t|
      t.integer :template_id
      t.string :from_email
      t.string :to_eamil
      t.string :subject
      t.integer :user_id
      t.integer :campaign_id

      t.timestamps
    end
  end
end
