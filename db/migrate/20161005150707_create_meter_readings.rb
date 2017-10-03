class CreateMeterReadings < ActiveRecord::Migration[5.0]
  def change
    create_table :meter_readings do |t|
      t.integer :meter_id
      t.float :current_reading
      t.float :previous_reading
      t.string :photo
      t.integer :reading_code
      t.float :latitude
      t.float :longitude
      t.integer :meter_reader_id
      t.float :distance
      t.float :quantity

      t.timestamps
    end
  end
end
