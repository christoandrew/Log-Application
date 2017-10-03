json.extract! town_zone, :id, :name, :address, :created_at, :updated_at
json.url admin_town_zones_url(townzone, format: :json)