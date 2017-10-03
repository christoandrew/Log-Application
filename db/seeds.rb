zones = Zone.all

zones.each do |zone|
  Route.create(name: "Route 1", town_id: zone.try(:town).try(:id), zone_id: zone.id)
end
