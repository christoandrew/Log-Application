class AdminController < ApplicationController
  before_action :authenticate_admin!
  :params_permit


  def index
    #@meter_readings = MeterReading.all

    csa_region_id = current_admin.region_id
    if current_admin.admin?
      	sql  = 'select meter_readings.*, meters.*, customers.*, towns.*, zones.* from meter_readings
                inner join meters on meter_readings.meter_id = meters.id inner join customers on 
                customers.no = meters.meter_number inner join towns on customers.town_id = towns.id
                inner join zones on zones.id  = customers.zone_id'
	readings = MeterReading.eager_load(:meter, meter: {customer: [:town, :zone]})

#	readings =MeterReading.connection.exec_query(sql) 
   else
      readings = MeterReading.eager_load(:meter, meter: {customer: [:town , :zone]}).where("towns.region_id = ?", csa_region_id)
    end
    @filterrific = initialize_filterrific(
        readings,
        params[:filterrific],
        :select_options => {
            sorted_by: MeterReading.options_for_sorted_by,
            with_town_id: Town.options_for_select,
            with_town_id_zone_id: Zone.options_for_select
        }
    ) or return
    @meter_readings = @filterrific.find.page(params[:page])
    @notifications = Notification.where(:is_read => false).all

    respond_to do |format|
      format.html
      format.js
      format.csv { send_data @meter_readings.to_csv, filename: "meterreadings-#{Date.today}.csv" }
      format.pdf do
        render pdf: 'file_name',
               layout: 'layouts/pdf.html.erb',
               show_as_html: params[:debug].present?
      end
    end

  end

  def admins
    cadmin = current_admin
    sql = "SELECT * FROM admins WHERE admins.id NOT IN ( SELECT id FROM admins WHERE admins.id = #{cadmin.id})"
    @admins = Admin.find_by_sql(sql)
  end

  def show_admin
    @admin = Admin.where(:id=>params[:id])
  end

  def new
    @admin = Admin.new
  end

  def create
    @zone = Admin.new(admin_params)

    respond_to do |format|
      if @zone.save
        #format.html { redirect_to admins_path, notice:'Admin was successfully created.' }
        format.json { render :show, status: :created, location: admin_zone_path(@zone) }
      else
        format.html { render :new }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  def admin_params
    params.require(:admin).permit(:email, :password, :town_id)
  end



end
