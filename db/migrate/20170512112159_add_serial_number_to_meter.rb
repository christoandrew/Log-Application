class AddSerialNumberToMeter < ActiveRecord::Migration[5.0]
  def change
    add_column :meters, :serial_number, :string
  end
end
