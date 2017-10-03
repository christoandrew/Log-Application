class Admin::TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, :except => :meter_reader_tasks
  before_action :set_notifications

  include TasksHelper
  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.includes(:town,:zone,:meter_reader,:route).all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  def import
    begin
      Task.save_the_day(params[:file])
      redirect_to admin_tasks_path, notice: "Assignments imported."
    end
  end

  def meter_reader_tasks
    render json: {:tasks => fetch_reader_tasks(params[:meter_reader_id])}
  end


  def meter_reader_tasks_since
    if params[:since] != null
      @tasks = Task.joins(:town).joins(:zone).joins(:route)
                   .select('tasks.id AS task_id,towns.name AS town_name,zones.name AS zone_name,tasks.status,
                  routes.name AS route_name,routes.id AS route_id,
                   zones.zone_code, towns.area_code,towns.id AS town_id,zones.id AS zone_id')
                   .where("meter_reader_id=? AND created_at >", params[:meter_reader_id], Time.at(params[:since].to_i / 1000).to_datetime)
    else
      @tasks = Task.joins(:town).joins(:zone).joins(:route)
                   .select('tasks.id AS task_id,towns.name AS town_name,zones.name AS zone_name,tasks.status,
                  routes.name AS route_name,routes.id AS route_id,
                   zones.zone_code, towns.area_code,towns.id AS town_id,zones.id AS zone_id,tasks.created_at AS created_at')
                   .where(:meter_reader_id => params[:meter_reader_id])
    end

    render json: {:tasks => @tasks}
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to admin_task_path(@task), notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: admin_task_path(@task) }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to admin_task_path(@task), notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_task_path(@task) }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to admin_tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def task_params
    params.require(:task).permit(:town_id, :zone_id, :route_id, :meter_reader_id, :status)
  end

  def set_notifications
    @notifications = Notification.where(:is_read => false).all
  end
end
