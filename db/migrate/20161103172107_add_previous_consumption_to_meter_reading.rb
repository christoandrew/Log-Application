class AddPreviousConsumptionToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :previous_consumption, :float
  end
end
