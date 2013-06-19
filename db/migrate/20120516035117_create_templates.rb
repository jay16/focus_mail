class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.string :file_name
      t.integer :img_url, :default => 2
      t.string :zip_url
      t.string :zip_name
      t.float :grade
      t.timestamps
    end
  end
end
