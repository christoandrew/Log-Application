
require 'rubygems'
require 'csv'
require 'roo'
class Town < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :area_code, presence: true, uniqueness: true
  has_many :zones
  has_many :meter_readings, through: :meter
  belongs_to :region
  has_many :admins
  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end


  def self.import(file)

    spread_sheet = open_spreadsheet(file)
    header = spread_sheet.row(1)
    (2..spread_sheet.last_row).each do |i|
      row = Hash[[header, spread_sheet.row(i)].transpose]
      name = row['Name']
      area = row['Code']
      puts row.to_json
      if Town.exists?(:area_code => area)
        puts find_by_area_code(area).to_json
      else
        town = Town.new
        town.name = name
        town.area_code = area
        town.save!
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

  def full_town_code
   @full_town_code = name+" - "+area_code
  end

end
