class RemoveTypeFromMeter < ActiveRecord::Migration[5.0]
  def change
    remove_column :meters, :type
  end
end
