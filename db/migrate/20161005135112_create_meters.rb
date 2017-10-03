class CreateMeters < ActiveRecord::Migration[5.0]
  def change
    create_table :meters do |t|
      t.integer :customer_id
      t.string :meter_number
      t.string :posting_group
      t.integer :zone_id
      t.integer :route_id
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
