json.extract! billing_period, "id", "start_date", "end_date", "created_at", "updated_at"
json.url admin_billing_period_url(billing_period, format: :json)