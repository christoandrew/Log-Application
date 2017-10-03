class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.integer :town_id
      t.integer :zone_id
      t.integer :route_id
      t.integer :meter_reader_id
      t.boolean :status

      t.timestamps
    end
  end
end
