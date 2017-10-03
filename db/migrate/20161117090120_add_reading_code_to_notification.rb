class AddReadingCodeToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :reading_code, :integer
  end
end
