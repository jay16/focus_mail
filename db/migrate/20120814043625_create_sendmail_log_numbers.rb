class CreateSendmailLogNumbers < ActiveRecord::Migration
  def change
    create_table :sendmail_log_numbers do |t|
      t.integer :number_log

      t.timestamps
    end
  end
end
