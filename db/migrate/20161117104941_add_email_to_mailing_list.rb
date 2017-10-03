class AddEmailToMailingList < ActiveRecord::Migration[5.0]
  def change
    add_column :mailing_lists, :email, :string
  end
end
