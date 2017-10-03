class RenameMeterReaderPasswordToPasswordDigest < ActiveRecord::Migration[5.0]
  def change
    rename_column :meter_readers, :password, :password_digest
  end
end
