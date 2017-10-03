class AddMeteredEntryToCustomer < ActiveRecord::Migration[5.0]
  def change
    add_column :customers, :metered_entry, :string
  end
end
