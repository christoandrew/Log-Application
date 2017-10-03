module RoutesHelper
  def fetch_routes
    routes = $redis.get('routes')
    if routes.nil?
      sql = 'select routes.name as route_name, routes.id as route_id, towns.name as town_name, zones.name as zone_name from
      routes inner join towns on towns.id = routes.id inner join zones on zones.id = routes.id'

      routes = Route.execute_find_sql(sql)
      $redis.set('routes', routes.to_json)
      # Expire the cache, every 5 hours
      $redis.expire('routes', 5.hour.to_i)
    end
    @customers = JSON.load routes
  end
end
