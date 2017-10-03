require 'csv'

class MeterReading < ApplicationRecord
  belongs_to :meter
  belongs_to :meter_reader
  belongs_to :billing_period

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
    joins(:meter, meter: {customer: :town}).where(
        terms.map {
          or_clauses = [
              "LOWER(meters.meter_number) LIKE ?",
              "LOWER(customers.name) LIKE ?",
              "LOWER(meters.posting_group) LIKE ?",
              "LOWER(customers.address) LIKE ?",
              'LOWER(meter_readings.is_metered_entry) LIKE ?',
              'towns.area_code LIKE ?',
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
        order("meter_readings.created_at #{ direction }")
      when /^name_/
        joins(meter: :customer).order("customers.name #{direction}")
      when /^town_name_/
        joins(:meter, meter: {customer: :town}).order("towns.name #{direction}")
    end
  }

  scope :with_town_id, lambda { |town_ids|
    all if town_ids.to_s.empty?
    joins(meter: :customer).where('customers.town_id=?', [*town_ids]).all
  }

  scope :with_town_id_zone_id, lambda { |zone_ids|
    all if zone_ids.to_s.empty?
    joins(meter: :customer).where('customers.zone_id=?', [*zone_ids]).all
  }

  def self.options_for_sorted_by
    [
        ['Customer Name (a-z)', 'name_asc'],
        ['Reading date (newest first)', 'created_at_desc'],
        ['Reading date (oldest first)', 'created_at_asc'],
        ['Town (a-z)', 'town_name_asc']
    ]
  end

    def self.save_the_day(file)
      readings = []
      spread_sheet = open_spreadsheet(file)
      header = spread_sheet.row(1)
      counter = 0
      (2..spread_sheet.last_row).each do |i|
        row = Hash[[header, spread_sheet.row(i)].transpose]
        no = row["No."]

        meter = Meter.find_by_meter_number(no).id
        current_reading = row["Meter Reading"]
        last_reading = row["Last Meter Reading"]
        reading_code = row["Meter Reading Code"]
        meter_reader_id = 98
        quantity = current_reading - last_reading
        billing_period_id = 4
        regular = true
	if meter
        reading = MeterReading.new(billing_period_id: billing_period_id, quantity: quantity, regular: regular,
                       meter_reader_id: meter_reader_id, current_reading: current_reading, previous_reading: last_reading,
                       meter_id: meter.id)
 	end
        readings << reading
      end
      MeterReading.import(readings)

      # Customer.import(customers)
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

  def decorated_created_at
    created_at.to_date.to_s(:long)
  end

  def self.to_csv
    attributes = %w{CustomerNo MeterReading Posted LastMeterReading LocationLatitude LocationLongitude QuantityFromPhone QuantityComputed MeterReadingCode CustomerDetails MeterReadingDate BillingPeriod StartDate EndDate}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |meter_reading|
        csv << [meter_reading.try(:meter).try(:meter_number), meter_reading.current_reading, meter_reading.posted, meter_reading.previous_reading, meter_reading.latitude, meter_reading.longitude, meter_reading.quantity, meter_reading.quantity, meter_reading.reading_code, meter_reading.customer_details, meter_reading.created_at, meter_reading.try(:billing_period).try(:start_date), meter_reading.try(:billing_period).try(:start_date), meter_reading.try(:billing_period).try(:end_date)]
      end
    end
  end

end
