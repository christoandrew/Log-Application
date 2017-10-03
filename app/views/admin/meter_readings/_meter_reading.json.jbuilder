json.extract! meter_reading, :id, :meter_id, :current_reading, :previous_reading, :photo, :reading_code, :created_at, :updated_at
json.url admin_meter_reading_url(meter_reading, format: :json)