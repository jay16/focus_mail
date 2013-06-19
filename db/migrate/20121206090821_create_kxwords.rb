class CreateKxwords < ActiveRecord::Migration
  def change
    create_table :kxwords do |t|
      t.string :content, :limit => 4000

      t.timestamps
    end
  end
end
