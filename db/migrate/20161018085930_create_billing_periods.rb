class CreateBillingPeriods < ActiveRecord::Migration[5.0]
  def change
    create_table :billing_periods do |t|
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
