class AddBillingPeriodIdToMeterReadings < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :billing_period_id, :integer
  end
end
