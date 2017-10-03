class CreateBulkMeters < ActiveRecord::Migration[5.0]
  def change
    create_table :bulk_meters do |t|
      t.integer :town_id
      t.integer :sr
      t.string :location
      t.string :meter_type
      t.integer :size
      t.string :serial_number

      t.timestamps
    end
  end
end
