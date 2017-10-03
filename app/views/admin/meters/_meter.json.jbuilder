json.extract! meter, :id, :customer_id, :meter_number, :posting_group, :zone_id, :created_at, :updated_at
json.url admin_meter_url(meter, format: :json)