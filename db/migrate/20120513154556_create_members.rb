class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :email
      t.integer :week_number
      t.integer :type_eamil, :default => 1

      t.timestamps
    end
  end
end
