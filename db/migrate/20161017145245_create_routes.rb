class CreateRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :routes do |t|
      t.string :name
      t.integer :zone_id

      t.timestamps
    end
  end
end
