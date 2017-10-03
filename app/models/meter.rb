require 'rubygems'
require 'csv'
require 'roo'
require 'activerecord-import'
class Meter < ApplicationRecord
  validates :customer_id, :meter_number, :zone_id, :posting_group, presence: true
  belongs_to :customer
  has_many :meter_readings
  belongs_to :route
  belongs_to :zone

  filterrific(
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
          :search_query,
          :sorted_by,
          :with_town_id,
          :with_town_id_zone_id
      ]
  )

  self.per_page = 10

  scope :search_query, lambda { |query|
    return nil if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 6
    includes(:customer, customer: [:town, :zone]).where(
        terms.map {
          or_clauses = [
              "LOWER(meters.meter_number) LIKE ?",
              "LOWER(customers.name) LIKE ?",
              "LOWER(customers.posting_group) LIKE ?",
              'towns.area_code LIKE ?',
              'zones.zone_code LIKE ?',
          ].join(' OR ')
          "(#{ or_clauses })"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'DESC' : 'ASC'
    case sort_option.to_s
      when /^created_at_/
        order("customers.created_at #{ direction }")
      when /^name_/
        order("customers.name #{direction}")
      when /^town_name_/
        includes(customer: :town).order("towns.name #{direction}")
    end
  }

  scope :with_town_id, lambda { |town_ids|
    all if town_ids.to_s.empty?
    includes(:customer).where('customers.town_id=?', [*town_ids]).all
  }

  scope :with_town_id_zone_id, lambda { |zone_ids|
    all if zone_ids.to_s.empty?
    includes(:customer).where('customers.zone_id=?', [*zone_ids]).all
  }


  def self.options_for_sorted_by
    [
        ['Customer Name (a-z)', 'name_asc'],
        ['Created date (newest first)', 'created_at_desc'],
        ['Created date (oldest first)', 'created_at_asc'],
        ['Town (a-z)', 'town_name_asc']
    ]
  end

  def self.save_the_day(file)
    meters = []
    spread_sheet = open_spreadsheet(file)

    header = spread_sheet.row(1)
    (2..spread_sheet.last_row).each do |i|
      row = Hash[[header, spread_sheet.row(i)].transpose]
      zone_code = row["Zone"]
      area = row["Area"]
      meter_number = row["No."]
      customer_name = row["Name"]
      posting_group = row["Posting Group Name"]
      latitude = row["Latitude"]
      longitude = row["Longitude"]
      serial_number = row["Meter Serial Number"]

      if serial_number.blank?
        serial_number = "No Serial Number"
      else
        serial_number = row["Meter Serial Number"]
      end

      # town = Town.find_by(:area_co
      customer = Customer.find_by(:meter_number => meter_number)
      zone = Zone.find_by(:zone_code => zone_code)
      if customer
        meter = Meter.new(customer_id: customer.id, posting_group: posting_group, zone_id: zone.id,
                          serial_number: serial_number, latitude: 0, longitude: 0, route_id: customer.route_id,
                          meter_number: meter_number)
      end
      meters << meter

    end
    Meter.import(meters)
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
