module ZonesHelper
  def fetch_customers(id)

@customers = Customer.joins(:route,:meter).where("customers.route_id=?",id)
          .select('customers.name AS customer_name,customers.address,customers.created_at AS created_at,
                        routes.name AS route_name, customers.id, routes.id AS route_id,
                        meters.id AS meter_id, customers.meter_number,meters.posting_group').to_json
      #$redis.set("zonecustomers"+id, customers)
      # Expire the cache, every 5 hours
     # $redis.expire("zonecustomers"+id, 5.hour.to_i)
    end

end
