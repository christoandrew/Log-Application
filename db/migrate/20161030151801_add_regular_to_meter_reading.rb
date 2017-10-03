class AddRegularToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :regular, :boolean
  end
end
