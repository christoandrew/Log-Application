module MeterReadingsHelper
  def fetch_readings
    readings = $redis.get("readings")
    if readings.nil?
      readings = MeterReading.all.to_json
      $redis.set("readings", readings)
      $redis.expire("readings",1.hour.to_i)
    end
    @readings = JSON.load readings
  end
end
