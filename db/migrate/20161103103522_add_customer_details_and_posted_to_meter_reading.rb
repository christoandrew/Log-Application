class AddCustomerDetailsAndPostedToMeterReading < ActiveRecord::Migration[5.0]
  def change
    add_column :meter_readings, :customer_details, :string
    add_column :meter_readings, :posted, :string
  end
end
