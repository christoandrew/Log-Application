class AddLastQuantityToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :last_quantity, :float
  end
end
