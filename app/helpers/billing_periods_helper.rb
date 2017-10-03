module BillingPeriodsHelper

  def fetch_billing_periods
    billing_periods = $redis.get("billing_periods")
    if billing_periods.nil?
      billing_periods = BillingPeriod.all.to_json
      $redis.set("billing_periods", billing_periods)
      $redis.expire("billing_periods", 5.hour.to_i)
    end
    @billing_periods = JSON.load billing_periods
  end
end
