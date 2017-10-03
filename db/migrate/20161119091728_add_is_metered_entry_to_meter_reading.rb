class AddIsMeteredEntryToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :is_metered_entry, :string
  end
end
