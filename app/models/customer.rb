require 'rubygems'
require 'csv'
require 'roo'
require 'activerecord-import'
class Customer < ApplicationRecord
  validates :name, :presence => true
  validates :address, :presence => true
  validates :route_id, :zone_id, :presence => true
  validates :town_id, :zone_id, :presence => true
  belongs_to :route
  has_one :meter
  belongs_to :town
  has_many :meter_readings, :through => :meter
  belongs_to :zone

  self.per_page = 10

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
    includes(:town, :zone).where(
        terms.map {
          or_clauses = [
              "LOWER(customers.no) LIKE ?",
              "LOWER(customers.name) LIKE ?",
              "LOWER(customers.posting_group) LIKE ?",
              "LOWER(customers.address) LIKE ?",
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
        includes(:town).order("towns.name #{direction}")
    end
  }

  scope :with_town_id, lambda { |town_ids|
    all if town_ids.to_s.empty?
    where('customers.town_id=?', [*town_ids]).all
  }

  scope :with_town_id_zone_id, lambda { |zone_ids|
    all if zone_ids.to_s.empty?
    where('customers.zone_id=?', [*zone_ids]).all
  }

  def self.options_for_sorted_by
    [
        ['Customer Name (a-z)', 'name_asc'],
        ['Registered date (newest first)', 'created_at_desc'],
        ['Registered date (oldest first)', 'created_at_asc'],
        ['Town (a-z)', 'town_name_asc']
    ]
  end


  def self.save_the_day(file)
    customers = []
    spread_sheet = open_spreadsheet(file)
    header = spread_sheet.row(1)
    counter = 0
    (2..spread_sheet.last_row).each do |i|
      row = Hash[[header, spread_sheet.row(i)].transpose]
      name = row["Name"]
      zone_code = row["Zone"]
      meter_number = row["No."]
      area_code = row["Area"]
      town = Town.find_by(:area_code => convert(area_code))
      zone = Zone.find_by(:zone_code => zone_code)
      address = row["Address"]
      posting_group = row["Posting Group Name"]
      metered_entry = row["Un-Metered Entry"]

      if address.blank?
        address_cust = "Address"
      else
        address_cust = address

      end

      route = Route.where(zone_id: zone.id).first
      customer = Customer.new(name: name, meter_number: meter_number,
                              #posting_group: posting_group,
                              town_id: town.id,
                              zone_id: zone.id,
                              address: address_cust,
                              metered_entry: metered_entry,
                              route_id: route.id)

      customers << customer
      puts customers.length
    end
    Customer.import(customers)
  end

  # end self.import(file)

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
