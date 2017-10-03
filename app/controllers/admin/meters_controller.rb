class Admin::MetersController < ApplicationController
  before_action :set_meter, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, :except => [:index, :show, :customer]
  before_action :set_notifications

  include CustomersHelper
  # GET /meters
  # GET /meters.json
  def index
    @filterrific = initialize_filterrific(
        Meter.includes(:route,customer: [:town,:zone]),
        params[:filterrific],
        :select_options => {
            sorted_by: Meter.options_for_sorted_by,
            with_town_id: Town.options_for_select,
            with_town_id_zone_id: Zone.options_for_select
        }
    ) or return
    @meters = @filterrific.find.page(params[:page])
  end

  # GET /meters/1
  # GET /meters/1.json
  def show
  end

  # GET /meters/new
  def new
    @meter = Meter.new
  end

  # GET /meters/1/edit
  def edit
  end

  def customer
    @meter = Meter.find_by_customer_id(params[:customer_id]);
    render json: @meter
  end

  def import
    begin
      Meter.save_the_day(params[:file])
      redirect_to admin_meters_path, notice: "Meters imported."
        #rescue
        #redirect_to admin_meters_path, notice: "Invalid file format."
    end
  end

  # POST /meters
  # POST /meters.json
  def create
    @meter = Meter.new(meter_params)

    respond_to do |format|
      if @meter.save
        format.html { redirect_to admin_meter_path(@meter), notice: 'Meter was successfully created.' }
        format.json { render :show, status: :created, location: admin_meter_path(@meter) }
      else
        format.html { render :new }
        format.json { render json: @meter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meters/1
  # PATCH/PUT /meters/1.json
  def update
    respond_to do |format|
      if @meter.update(meter_params)
        format.html { redirect_to admin_meter_path(@meter), notice: 'Meter was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_meter_path(@meter) }
      else
        format.html { render :edit }
        format.json { render json: @meter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meters/1
  # DELETE /meters/1.json
  def destroy
    @meter.destroy
    respond_to do |format|
      format.html { redirect_to admin_meters_url, notice: 'Meter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_meter
    @meter = Meter.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def meter_params
    params.require(:meter).permit(:customer_id, :meter_number, :latitude, :longitude, :posting_group,
                                  :status, :serial_number, :quantity, :zone_id, :route_id)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
