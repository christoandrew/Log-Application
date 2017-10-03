class BillingPeriod < ApplicationRecord
  has_many :meter_readings
  def name_with_initial
    "#{start_date} to  #{end_date}"
  end
end
