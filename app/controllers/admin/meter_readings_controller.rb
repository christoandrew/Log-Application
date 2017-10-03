require 'will_paginate/array' 
class Admin::MeterReadingsController < ApplicationController
  before_action :set_meter_reading, only: [:show, :edit, :update, :destroy]
  before_action :set_notifications
  include MeterReadingsHelper
  # GET /meter_readings GET /meter_readings.json
  def index
    #@meter_readings = MeterReading.all
    @filterrific = initialize_filterrific(
        MeterReading,
        params[:filterrific],
        :select_options => {
            sorted_by: MeterReading.options_for_sorted_by,
            with_town_id: MeterReading.with_town_id,
            with_town_id_zone_id: MeterReading.with_town_id_zone_id
        }
    ) or return
    @meter_readings = @filterrific.find.page(params[:page])
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render pdf: 'file_name',
               layout: 'layouts/pdf.html.erb',
               show_as_html: params[:debug].present?
      end
      format.csv { send_data @meter_readings.to_csv, filename: "meterreadings-#{Date.today}.csv" }
    end
  end
  def import
    begin
      MeterReading.save_the_day(params[:file])
      redirect_to admin_meter_readers_path, notice: "Readers imported."
    end
  end
  def readings
    render :json=>fetch_readings
  end
  def skipped_meters
    @billing_periods = BillingPeriod.all
    if params[:billing_period].blank?
      billing_period = BillingPeriod.first.id
    else
      billing_period = params[:billing_period]
    end
    @skipped_data = []
    sql = "select meters.* from meters where not exists(select null from meter_readings where meter_readings.meter_id = meters.id and 
meter_readings.billing_period_id=#{billing_period})"
    @skipped_meters =Meter.find_by_sql(sql)
    @skipped_meters.each do |meter|
      customer = meter.try(:customer)
      route = customer.try(:route)
      task = route.try(:task)
      meter_reader = task.try(:meter_reader)
      last_reading = MeterReading.where(:meter_id => meter.id).order('created_at').last
      skipped_hash = {"customer": customer.try(:name), "meter_reader": meter_reader.try(:name), "meter_number": meter.try(:meter_number),
                      "last_reading": last_reading.try(:created_at), "town": customer.try(:town).try(:name), "zone": customer.try(:zone).try(:name), "latitude": 
meter.latitude,
                      "longitude": meter.longitude}
      @skipped_data.push(skipped_hash)
    end
  end
  def reader_performance
    @billing_periods = BillingPeriod.all
    @meter_readers = MeterReader.all
    if params[:billing_period].blank?
      billing_period = BillingPeriod.first.id
    else
      billing_period = params[:billing_period]
    end
    @array = []
    @meter_readers.each do |meter_reader|
      task = meter_reader.try(:tasks).first
      read_meters = MeterReading.select('DISTINCT meter_id').where('meter_reader_id =? AND billing_period_id=?', meter_reader.id, billing_period)
      skipped_meters_sql = "select meters.* from meters where not exists(select null from meter_readings
                where meter_readings.meter_id = meters.id and meter_readings.billing_period_id=1
                and meter_readings.meter_reader_id=#{meter_reader.id})"
      skipped_meters = Meter.find_by_sql(skipped_meters_sql)
      irregular_readings = MeterReading.where('meter_reader_id =? AND billing_period_id=? AND regular=false', meter_reader.id, billing_period)
      route_accuracy = MeterReading.select("*").where("meter_reader_id =? AND billing_period_id=?", meter_reader.id, billing_period);
      hash = {"read_meters": read_meters.count, "skipped_meters": skipped_meters.count, "irregular_readings": irregular_readings.count,
              "route_accuracy": route_accuracy.average(:distance), "town": task.try(:town).try(:name), "zone": task.try(:zone).try(:name),
              "name": meter_reader.name}
      @array.push(hash)
    end
    render 'admin/meter_readings/reader_performance'
  end
  # GET /meter_readings/1 GET /meter_readings/1.json
  def show
  end
  def today
    @meter_readings = MeterReading.where('created_at >= ?', Time.zone.now.beginning_of_day)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Meter Readings#{Date.today}",
               layout: 'layouts/pdf.html.erb',
               show_as_html: params[:debug].present?,
               orientation: 'Landscape'
      end
      format.csv { send_data @meter_readings.to_csv, filename: "today-meterreadings-#{Date.today}.csv" }
    end
  end
  def faulty_unclear
    @meter_readings = MeterReading.where('created_at >= ? AND (reading_code=? OR reading_code=?)', Time.zone.now.beginning_of_day, 13, 18)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'file_name',
               layout: 'layouts/pdf.html.erb',
               show_as_html: params[:debug].present?
      end
      format.csv { send_data @meter_readings.to_csv, filename: "faulty-unclear-meterreadings-#{Date.today}.csv" }
    end
  end
  def today_irregular
    @irregular_readings = MeterReading.where('meter_readings.regular = false AND created_at >= ?', Time.zone.now.beginning_of_day)
  end
  # GET /meter_readings/new
  def new
    @meter_reading = MeterReading.new
  end
  # GET /meter_readings/1/edit
  def edit
  end
  def meter_reading
    @reading = MeterReading.where(:meter_id => params[:meter_id]).order('created_at').last
    render json: @reading
  end
  def new_reading
    sleep(1.seconds)
    @reading = MeterReading.new(meter_reading_params)
    @notification = Notification.new
    meter = Meter.find_by_id(@reading.meter_id)
    customer = meter.try(:customer)
    if params[:reading_code] == 1 || 10 || 13 || 18
      case params[:reading_code]
        when 1
          @notification.title = "No access to property"
          @notification.reading_code = @reading.reading_code
          @notification.text = "No access to property for meter #{@reading.try(:meter).try(:meter_number)}
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 10
          @notification.title = "Damaged Meter"
          @notification.reading_code = @reading.reading_code
          @notification.text = "There is a damaged meter #{@reading.try(:meter).try(:meter_number)}
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 13
          @notification.title = " Unclear meter "
          @notification.reading_code = @reading.reading_code
          @notification.text = " There is an unclear meter #{@reading.try(:meter).try(:meter_number)}
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 18
          @notification.title = "Faulty meter"
          @notification.reading_code = @reading.reading_code
          @notification.text = " #{@reading.try(:meter).try(:meter_number)} is faulty
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 19
          @notification.title = "Customer bypass"
          @notification.reading_code = @reading.reading_code
          @notification.text = "#{@reading.try(:meter).try(:meter_number)} has a bypass
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to Customer: #{customer.try(:name)}"
          @notification.is_read = false
      end
    end
    @existing = MeterReading.find_by_client_id_and_meter_id(params[:client_id], params[:meter_id])
    if MeterReading.exists?(:meter_id=>params[:meter_id],:client_id=>params[:client_id])
      render :json => @existing
    else
      if @reading.save
        @notification.save
        render json: @reading
      end
    end
  end
  # POST /meter_readings POST /meter_readings.json
  def create
    @meter_reading = MeterReading.new(meter_reading_params)
    @notification = Notification.new
    if @meter_reading.reading_code != 7
      meter = Meter.find_by_id(@meter_reading.meter_id)
      customer = meter.try(:customer)
      case @meter_reading.reading_code
        when 1
          @notification.title = "No access to property"
          @notification.reading_code = @meter_reading.reading_code
          @notification.text = "No access to property for meter #{meter.meter_number}
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 10
          @notification.title = "Damaged Meter"
          @notification.reading_code = @meter_reading.reading_code
          @notification.text = "There is a damaged meter #{@meter_reading.meter.meter_number}
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 13
          @notification.title = " Unclear meter "
          @notification.reading_code = @meter_reading.reading_code
          @notification.text = " There is an unclear meter #{@meter_reading.meter.meter_number}
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 18
          @notification.title = "Faulty meter"
          @notification.reading_code = @meter_reading.reading_code
          @notification.text = " #{@meter_reading.meter.meter_number} is faulty
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to #{customer.try(:name)}"
          @notification.is_read = false
        when 19
          @notification.title = "Customer bypass"
          @notification.reading_code = @meter_reading.reading_code
          @notification.text = "#{@meter_reading.meter.meter_number} has a bypass
          located in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on #{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to Customer: #{customer.try(:name)}"
          @notification.is_read = false
      end
    end
    respond_to do |format|
      if @meter_reading.save && @notification.save
        if !@meter_reading.regular
          title = "Irregular meter reading"
          reading_code = @meter_reading.reading_code
          message = "There has been an irregular reading in#{customer.try(:town).try(:name)}, #{customer.try(:zone).try(:name)} on 
#{customer.try(:route).try(:name)}
          at #{customer.try(:address)} belonging to Customer: #{customer.try(:name)
          } by #{@meter_reading.try(:meter_reader).try(:name)}"
          @notify_irregular = Notification.new
          @notify_irregular.title = title;
          @notify_irregular.text = message
          @notify_irregular.reading_code= @meter_reading.reading_code
          @notify_irregular.is_read = false
          if @notify_irregular.save
            #AdminMailer.notify_email(title, message).deliver_later
          end
        end
        #AdminMailer.notify_email(@notification.title, @notification.text).deliver_later
        format.html { redirect_to admin_meter_reading_path(@meter_reading), notice: 'Meter reading was successfully created.' }
        format.json { render :show, status: :created, location: admin_meter_reading_path(@meter_reading) }
      else
        format.html { render :new }
        format.json { render json: @meter_reading.errors, status: :unprocessable_entity }
      end
    end
  end
  # PATCH/PUT /meter_readings/1 PATCH/PUT /meter_readings/1.json
  def update
    respond_to do |format|
      if @meter_reading.update(meter_reading_params)
        format.html { redirect_to admin_meter_reading_path(@meter_reading), notice: 'Meter reading was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_meter_reading_path(@meter_reading) }
      else
        format.html { render :edit }
        format.json { render json: @meter_reading.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /meter_readings/1 DELETE /meter_readings/1.json
  def destroy
    @meter_reading.destroy
    respond_to do |format|
      format.html { redirect_to admin_meter_readings_url, notice: 'Meter reading was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_meter_reading
    @meter_reading = MeterReading.find(params[:id])
  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def meter_reading_params
    params.permit(:meter_id, :current_reading,:last_quantity, :previous_reading, :latitude, :billing_period_id,:client_id,
                                          :longitude, :regular, :meter_reader_id, :quantity, :distance, :photo, :is_metered_entry,:reading_code, :reason, 
                                         :customer_details, :posted, :previous_consumption, :expected_range)
  end
  def set_notifications
    @notifications = Notification.order("created_at DESC").where(:is_read => false)
  end
  def error_before_saving
    false
  end
  def error_after_saving
    false
  end end
