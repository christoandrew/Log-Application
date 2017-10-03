class Zone < ApplicationRecord
  validates :zone_code, uniqueness: true, presence: true

  belongs_to :town
  has_many :routes

  def self.options_for_select
    #where(:town_id=>town_id).order('LOWER(name)').map { |e| [e.name, e.id] }
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

  def full_zone_code
    @full_zone_code = name+" - "+zone_code
  end

  def self.import(file)

    spread_sheet = open_spreadsheet(file)

    header = spread_sheet.row(1)
    (2..spread_sheet.last_row).each do |i|
      row = Hash[[header, spread_sheet.row(i)].transpose]
      name = row['Name']
      zone_code = row["Code"]
      area = row["Area"]

      puts area
      if Town.exists?(:area_code => area)
        town = Town.find_by(:area_code => area)
        if exists?(:zone_code => zone_code)

        else
          zone = Zone.new
          zone.name = name
          zone.zone_code = zone_code
          zone.town_id = town.id
          puts zone.to_json
          zone.save!
        end
      end
    end
  end

  # end self.import(file)


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
