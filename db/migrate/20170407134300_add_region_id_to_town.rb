class AddRegionIdToTown < ActiveRecord::Migration[5.0]
  def change
    add_column :towns, :region_id, :integer
  end
end
