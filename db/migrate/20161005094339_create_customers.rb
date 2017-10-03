class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :address
      t.integer :route_id
      t.integer :zone_id
      t.timestamps
    end
  end
end
