json.extract! customer, "id", "name", "address", "created_at", "updated_at"
json.url admin_customer_url(customer, format: :json)