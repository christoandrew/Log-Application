json.extract! notification, :id, :title, :text, :is_read, :created_at, :updated_at
json.url notification_url(notification, format: :json)