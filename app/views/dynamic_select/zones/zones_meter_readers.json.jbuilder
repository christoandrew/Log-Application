json.array!(@meter_readers) do |meter_reader|
  json.extract! route, :name, :id
end
