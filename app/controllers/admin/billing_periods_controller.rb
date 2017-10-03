class Admin::BillingPeriodsController < ApplicationController
  before_action only: [:show, :edit, :update, :destroy]
  before_action :set_notifications

  include BillingPeriodsHelper
  # GET /billing_periods
  # GET /billing_periods.json
  def index
    fetch_billing_periods
  end

  # GET /billing_periods/1
  # GET /billing_periods/1.json
  def show
    @meter_readings = MeterReading.where(:billing_period_id => params[:id])
  end

  # GET /billing_periods/new
  def new
    @billing_period = BillingPeriod.new
  end

  # GET /billing_periods/1/edit
  def edit
    set_billing_period
  end

  def billing_period
    @billing_period = BillingPeriod.where(:id => params[:billing_period_id]).last;
    render json: @billing_period.to_json
  end

  # POST /billing_periods
  # POST /billing_periods.json
  def create
    @billing_period = BillingPeriod.new(billing_period_params)

    respond_to do |format|
      if @billing_period.save
        format.html { redirect_to admin_billing_period_path(@billing_period), notice: 'Billing period was successfully created.' }
        format.json { render :show, status: :created, location: admin_billing_period_path(@billing_period) }
      else
        format.html { render :new }
        format.json { render json: @billing_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /billing_periods/1
  # PATCH/PUT /billing_periods/1.json
  def update
    set_billing_period
    respond_to do |format|
      if @billing_period.update(billing_period_params)
        format.html { redirect_to admin_billing_period_path(@billing_period), notice: 'Billing period was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_billing_period_path(@billing_period) }
      else
        format.html { render :edit }
        format.json { render json: @billing_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /billing_periods/1
  # DELETE /billing_periods/1.json
  def destroy
    set_billing_period
    @billing_period.destroy
    respond_to do |format|
      format.html { redirect_to admin_billing_periods_url, notice: 'Billing period was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_billing_period
    @billing_period = BillingPeriod.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def billing_period_params
    params.require(:billing_period).permit(:start_date, :end_date)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
