class CreateSendmailLogs < ActiveRecord::Migration
  def change
    create_table :sendmail_logs do |t|
      t.datetime :send_date
      t.string :course_id
      t.string :type_email
      t.string :from_email
      t.string :to_email
      t.string :title_email
      t.string :tf_email
      t.string :test1
      t.string :test2
      t.string :coding_email
      t.string :campaign_id

      t.timestamps
    end
  end
end
