class AddTownIdToCustomers < ActiveRecord::Migration[5.0]
  def change
    add_column :customers, :town_id, :integer
  end
end
