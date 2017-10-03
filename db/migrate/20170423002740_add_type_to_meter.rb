class AddTypeToMeter < ActiveRecord::Migration[5.0]
  def change
    add_column :meters, :type, :string
  end
end
