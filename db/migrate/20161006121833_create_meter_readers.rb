class CreateMeterReaders < ActiveRecord::Migration[5.0]
  def change
    create_table :meter_readers do |t|
      t.string :name
      t.string :username
      t.string :email
      t.string :password
      t.timestamps
    end
    add_index :meter_readers, :email, unique: true
  end
end
