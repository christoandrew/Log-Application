class AddMeterIdToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :meter_id, :integer
  end
end
