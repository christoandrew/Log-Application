class Admin::TownsController < ApplicationController
  before_action :set_town, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, except: [:zones, :routes]
  before_action :set_notifications

  # GET /towns
  # GET /towns.json
  def index
    @towns = Town.all

  end

  # GET /towns/1
  # GET /towns/1.json
  def show
  end

  def import
    begin
      Town.import(params[:file])
      redirect_to admin_towns_path, notice: "Towns imported."
    #rescue
      #redirect_to admin_towns_path, notice: "Invalid CSV file format."
    end
  end

  # GET /towns/new
  def new
    @town = Town.new
  end

  # GET /towns/1/edit
  def edit
  end

  def zones
    @zones = Zone.joins(:town)
                 .select('zones.name AS zone_name, zones.zone_code, zones.id,
                  towns.name AS town_name, towns.area_code,towns.id AS town_id')

    render json: @zones.to_json
  end


  # POST /towns
  # POST /towns.json
  def create
    @town = Town.new(town_params)

    respond_to do |format|
      if @town.save
        format.html { redirect_to admin_town_path(@town), notice: 'Town was successfully created.' }
        format.json { render :show, status: :created, location: admin_town_path(@town) }
      else
        format.html { render :new }
        format.json { render json: @town.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /towns/1
  # PATCH/PUT /towns/1.json
  def update
    respond_to do |format|
      if @town.update(town_params)
        format.html { redirect_to admin_town_path(@town), notice: 'Town was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_town_path(@town) }
      else
        format.html { render :edit }
        format.json { render json: @town.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /towns/1
  # DELETE /towns/1.json
  def destroy
    @town.destroy
    respond_to do |format|
      format.html { redirect_to admin_towns_url, notice: 'Town was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_town
    @town = Town.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def town_params
    params.require(:town).permit(:name, :area_code)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
