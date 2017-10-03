class AddExpectedRangeToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :expected_range, :string
  end
end
