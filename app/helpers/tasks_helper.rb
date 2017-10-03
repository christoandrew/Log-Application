module TasksHelper
  def fetch_reader_tasks(id)
    tasks = $redis.get("tasks"+id)
    if tasks.nil?
      tasks = Task.joins(:town).joins(:zone).joins(:route)
          .select('tasks.id AS id, tasks.id AS task_id,towns.name AS town_name,tasks.meter_reader_id AS meter_reader_id,
                  zones.name AS zone_name,tasks.status,routes.name AS route_name,routes.id AS route_id,
                   zones.zone_code, towns.area_code,towns.id AS town_id,zones.id AS zone_id,
                  tasks.created_at AS created_at')
          .where(:meter_reader_id => id).to_json
      $redis.set("tasks"+id, tasks)
      $redis.expire("tasks"+id, 5.hour.to_i)
    end
    @tasks = JSON.load tasks
  end
end
