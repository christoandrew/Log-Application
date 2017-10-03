class CreateZones < ActiveRecord::Migration[5.0]
  def change
    create_table :zones do |t|
      t.string :name
      t.string :zone_code
      t.integer :town_id

      t.timestamps
    end
  end
end
