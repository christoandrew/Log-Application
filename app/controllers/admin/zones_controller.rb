class Admin::ZonesController < ApplicationController
  before_action :set_zone, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, except: [:customers, :index, :customers, :routes]
  before_action :set_notifications

  include ZonesHelper

  # GET /zones
  # GET /zones.json
  def index
    @zones = Zone.includes(:town).all

  end

  # GET /zones/1
  # GET /zones/1.json
  def show
  end

  # GET /zones/new
  def new
    @zone = Zone.new
  end

  def import
    begin
      Zone.import(params[:file])
      redirect_to admin_zones_path, notice: 'Zones imported.'
    end
  end

  # GET /zones/1/edit
  def edit
  end

  def routes
    @routes = Route.where(:zone_id => params[:zone_id])
    render json: @routes
  end

  def customers
    render json: fetch_customers(params[:route_id])
  end

  def meter_readers
    #@meter_readers = MeterReader.where()
  end

  # POST /zones
  # POST /zones.json
  def create
    @zone = Zone.new(zone_params)

    respond_to do |format|
      if @zone.save
        format.html { redirect_to admin_zone_path(@zone), notice: 'Zone was successfully created.' }
        format.json { render :show, status: :created, location: admin_zone_path(@zone) }
      else
        format.html { render :new }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /zones/1
  # PATCH/PUT /zones/1.json
  def update
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to admin_zone_path(@zone), notice: 'Zone was successfully updated.' }
        format.json { render :show, status: :ok, location: @zone }
      else
        format.html { render :edit }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1
  # DELETE /zones/1.json
  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to admin_zones_url, notice: 'Zone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_zone
    @zone = Zone.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def zone_params
    params.require(:zone).permit(:name, :zone_code, :town_id)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
