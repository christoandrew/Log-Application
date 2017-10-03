module CustomersHelper
  def fetch_customers
    customers = $redis.get("customers")

    if customers.nil?
      sql = "select customers.*, zones.name as zone_name, customers.address,meters.meter_number, meters.posting_group, towns.name as town_name, towns.area_code, zones.zone_code
from customers inner join zones on customers.zone_id = zones.id inner join
towns on towns.id = customers.town_id inner join meters on meters.customer_id = customers.id"
      customers = Customer.find_by_sql(sql).to_json
      $redis.set("customers", customers)
      # Expire the cache, every 5 hours
      $redis.expire("customers", 5.hour.to_i)
    end
    @customers = JSON.load customers
  end
end
