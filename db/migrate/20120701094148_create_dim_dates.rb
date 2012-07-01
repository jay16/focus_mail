class CreateDimDates < ActiveRecord::Migration
  def change
    create_table :dim_dates do |t|
      t.datetime :date_d
      t.string :date_s
      t.integer :date_y
      t.integer :date_q
      t.integer :date_m
      t.integer :date_w
      t.integer :date_wn

      t.timestamps
    end
  end
end
