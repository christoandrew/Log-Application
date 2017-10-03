class AddMeterNumberToCustomer < ActiveRecord::Migration[5.0]
  def change
    add_column :customers, :meter_number, :string
  end
end
