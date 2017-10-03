class Admin::BulkMetersController < ApplicationController
  before_action :set_bulk_meter, only: [:show, :edit, :update, :destroy]

  # GET /bulk_meters
  # GET /bulk_meters.json
  def index
    @bulk_meters = BulkMeter.all
  end

  # GET /bulk_meters/1
  # GET /bulk_meters/1.json
  def show
  end

  # GET /bulk_meters/new
  def new
    @bulk_meter = BulkMeter.new
  end

  # GET /bulk_meters/1/edit
  def edit
  end

  # POST /bulk_meters
  # POST /bulk_meters.json
  def create
    @bulk_meter = BulkMeter.new(bulk_meter_params)

    respond_to do |format|
      if @bulk_meter.save
        format.html { redirect_to @bulk_meter, notice: 'Bulk meter was successfully created.' }
        format.json { render :show, status: :created, location: @bulk_meter }
      else
        format.html { render :new }
        format.json { render json: @bulk_meter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bulk_meters/1
  # PATCH/PUT /bulk_meters/1.json
  def update
    respond_to do |format|
      if @bulk_meter.update(bulk_meter_params)
        format.html { redirect_to @bulk_meter, notice: 'Bulk meter was successfully updated.' }
        format.json { render :show, status: :ok, location: @bulk_meter }
      else
        format.html { render :edit }
        format.json { render json: @bulk_meter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulk_meters/1
  # DELETE /bulk_meters/1.json
  def destroy
    @bulk_meter.destroy
    respond_to do |format|
      format.html { redirect_to bulk_meters_url, notice: 'Bulk meter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    begin
      BulkMeter.save_the_day(params[:file])
      redirect_to admin_bulk_meters_path, notice: "Bulk Meters imported."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bulk_meter
      @bulk_meter = BulkMeter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bulk_meter_params
      params.require(:bulk_meter).permit(:town_id, :sr, :location, :meter_type, :size, :serial_number)
    end
end
