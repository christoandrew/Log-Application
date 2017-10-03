class AddReasonToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :reason, :text
  end
end
