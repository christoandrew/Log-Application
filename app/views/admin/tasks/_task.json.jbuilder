json.extract! task, :id, :town_id, :zone_id, :route_id, :meter_reader_id, :status, :created_at, :updated_at
json.url task_url(task, format: :json)