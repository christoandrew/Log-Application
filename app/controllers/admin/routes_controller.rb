class Admin::RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, except: [:customers, :index, :customers]
  before_action :set_notifications

  # GET /routes
  # GET /routes.json
  include RoutesHelper
  def index
    @routes = Route.includes(:town,:zone).all
    @notifications = Notification.where(:is_read => false).all
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
  end

  # GET /routes/new
  def new
    @route = Route.new
  end


  def customers
    @customers = Customer.joins(:route).joins(:meter).where(:route_id => params[:route_id])
                     .select('customers.name AS customer_name,customers.address,
                        routes.name AS route_name, customers.id, routes.id AS route_id,
                        meters.id AS meter_id, meters.meter_number,meters.posting_group')
    render json: {:customers=>@customers}
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(route_params)

    respond_to do |format|
      if @route.save
        format.html { redirect_to admin_route_url(@route), notice: 'Route was successfully created.' }
        format.json { render :show, status: :created, location: admin_route_url(@route) }
      else
        format.html { render :new }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    respond_to do |format|
      if @route.update(route_params)
        format.html { redirect_to admin_route_url(@route), notice: 'Route was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_route_url(@route) }
      else
        format.html { render :edit }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.destroy
    respond_to do |format|
      format.html { redirect_to admin_routes_url, notice: 'Route was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_route
    @route = Route.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def route_params
    params.require(:route).permit(:name, :zone_id, :town_id)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
