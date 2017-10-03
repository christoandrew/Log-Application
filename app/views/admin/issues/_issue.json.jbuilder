json.extract! issue, :id, :title, :text, :meter_reader_id, :created_at, :updated_at
json.url issue_url(issue, format: :json)