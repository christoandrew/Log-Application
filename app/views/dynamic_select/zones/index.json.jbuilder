json.array!(@zones) do |zone|
  json.extract! zone, :name, :id, :zone_code
end
