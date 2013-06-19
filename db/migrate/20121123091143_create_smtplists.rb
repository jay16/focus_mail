class CreateSmtplists < ActiveRecord::Migration
  def change
    create_table :smtplists do |t|
      t.string :domain
      t.string :email_name
      t.string :email_pwd
      t.string :email_smtp
      t.string :email_port
      t.string :login_name

      t.timestamps
    end
  end
end
