class Admin::CustomersController < AdminController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, except: :index
  before_action :set_notifications
  # GET /customers
  # GET /customers.json
  include CustomersHelper
  def index
    @filterrific = initialize_filterrific(
        Customer.includes(:town, :zone),
        params[:filterrific],
        :select_options => {
            sorted_by: Customer.options_for_sorted_by,
            with_town_id: Town.options_for_select,
            with_town_id_zone_id: Zone.options_for_select
        }
    ) or return
    @customers = @filterrific.find.page(params[:page])
  end

  def all_customers
    fetch_customers
    customer_array = []
    @customers.each do |customer|
      customer_new = CustomerReading.new
      customer_new.id = customer["id"]
      customer_new.customer_name = customer["name"]
      customer_new.address = customer["address"]

      #reading = MeterReading.where("meter_id = ?").order('created_at').last
      #customer_new.last_reading_code = @reading.reading_code
      customer_array.push(customer_new)
    end
    render :json => @customers
  end

  def new
    @customer = Customer.new
  end


  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to admin_customer_path(@customer), notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: admin_customer_path(@customer) }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to admin_customer_path(@customer), notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_customer_path(@customer) }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to admin_customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    begin
      Customer.save_the_day(params[:file])
      redirect_to admin_customers_path, notice: "Customers imported."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def customer_params
    params.require(:customer).permit(:name, :address, :zone_id, :route_id,:town_id,:file)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
