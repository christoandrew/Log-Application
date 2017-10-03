class Task < ApplicationRecord
  belongs_to :meter_reader
  belongs_to :town
  belongs_to :zone
  belongs_to :route

  def self.save_the_day(file)
    tasks = []
    spread_sheet = open_spreadsheet(file)
    header = spread_sheet.row(1)
    counter = 0
    (2..spread_sheet.last_row).each do |i|
      row = Hash[[header, spread_sheet.row(i)].transpose]
      town = row["Town"]
      zone = row["Zone"]
      name = row["Name"]

      zone_i = Zone.find_by(zone_code: zone)
      zone_id = zone_i.id
      town_id = Town.find_by(area_code: convert(town)).id
      route_id = Route.find_by(zone_id: zone_id).id
      reader = MeterReader.find_by(name: name)
      reader_id = reader.id;
      task = Task.new(town_id: town_id, zone_id: zone_id, route_id: route_id, meter_reader_id: reader_id, status: true)

      tasks << task
    end
    Task.import(tasks)

    # Customer.import(customers)
  end
  def self.convert x
    Float(x)
    i, f = x.to_i, x.to_f
    i == f ? i : f
  rescue ArgumentError
    x
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then
        Roo::CSV.new(file.path, nil, :ignore)
      when '.xls' then
        Roo::Excel.new(file.path, nil, :ignore)
      when '.xlsx' then
        Roo::Excelx.new(file.path)
      else
        raise "Unknown file type: #{file.original_filename}"
    end
  end

end
