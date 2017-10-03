class AddTownIdToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :town_id, :integer
  end
end
