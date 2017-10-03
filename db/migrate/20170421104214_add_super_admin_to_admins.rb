class AddSuperAdminToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :admin, :boolean
  end
end
