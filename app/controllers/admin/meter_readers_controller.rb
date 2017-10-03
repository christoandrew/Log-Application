class Admin::MeterReadersController < ApplicationController
  before_action :set_meter_reader, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, :except => :auth
  before_action :set_notifications

  # GET /meter_readers
  # GET /meter_readers.json
  def index
    @meter_readers = MeterReader.all
  end

  # GET /meter_readers/1
  # GET /meter_readers/1.json
  def show
    @tasks = Task.where(:meter_reader_id => params[:id])
    @towns = Town.all
    @zones = Zone.where(:town_id => Town.first.id)
  end

  def update_zones
    @zones = Zone.where('town_id = ?', params[:town_id])
    respond_to do |format|
      format.js render @zones
    end
  end

  def create_task

  end

  def new_task
    @task = Task.new
  end

  def edit_task

  end

  # GET /meter_readers/new
  def new
    @meter_reader = MeterReader.new
  end

  # GET /meter_readers/1/edit
  def edit
  end

  def login

  end

  def import
    begin
      MeterReader.save_the_day(params[:file])
      redirect_to admin_meter_readers_path, notice: "Readers imported."
    end
  end
  # POST /meter_readers
  # POST /meter_readers.json
  def create
    @meter_reader = MeterReader.new(meter_reader_params)

    respond_to do |format|
      if @meter_reader.save
        format.html { redirect_to admin_meter_reader_path(@meter_reader), notice: 'Meter reader was successfully created.' }
        format.json { render :show, status: :created, location: admin_meter_reader_path(@meter_reader) }
      else
        format.html { render :new }
        format.json { render json: @meter_reader.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meter_readers/1
  # PATCH/PUT /meter_readers/1.json
  def update
    respond_to do |format|
      if @meter_reader.update(meter_reader_params)
        format.html { redirect_to admin_meter_reader_path(@meter_reader), notice: 'Meter reader was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_meter_reader_path(@meter_reader) }
      else
        format.html { render :edit }
        format.json { render json: @meter_reader.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meter_readers/1
  # DELETE /meter_readers/1.json
  def destroy
    @meter_reader.destroy
    respond_to do |format|
      format.html { redirect_to admin_meter_readers_url, notice: 'Meter reader was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def auth
    meter_reader = MeterReader.where('username = ?', params[:username]).first
    # If the user exists AND the password entered is correct.
    if meter_reader && meter_reader.authenticate(params[:password])
      render :json => meter_reader
    else
      render json: {status: 'not ok'}
    end

    #render @reader.inspect

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_meter_reader
    @meter_reader = MeterReader.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def meter_reader_params
    params.require(:meter_reader).permit(:name, :email, :password_digest, :password, :username)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
