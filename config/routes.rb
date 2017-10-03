Rails.application.routes.draw do

  resources :bulk_meters
  devise_for :meter_readers
  devise_for :admins
  resources :users_admin, :controller => 'admin'

  root 'admin#index'
  namespace :admin do
    resources :customers, :towns, :zones, :meters, :meter_readers, :meter_readings, :routes,
              :billing_periods, :tasks, :issues, :notifications, :mailing_lists,:regions, :bulk_meters do
      collection { post :import }
    end
  end
  namespace :dynamic_select do
    get ':town_id/zones', to: 'zones#index', as: 'zones'
    get ':zone_id/routes', to: 'zones#zones_routes', as: 'routes'
    get ':zone_id/meter_readers', to: 'zones#zones_meter_readers', as: 'meter_readers'

  end

  get 'admin/admins' => 'admin#admins'
  get 'admin/show/:id' => 'admin#show_admin', as: 'show_admin'

  get 'admin/readings' => 'admin/meter_readings#readings'

  post 'admin/new_reading' => 'admin/meter_readings#new_reading'

  get 'admin/all_customers' => 'admin/customers#all_customers'
  get 'admin/new' => 'admin#new'

  get 'admin/meter_readers/:id/new_task' => 'admin/meter_readers#new_task', :as => '/new_task'
  get 'admin/meter_readers/task/:id/edit' => 'admin/meter_readers#edit_task'
  post 'admin/meter_readers/:id/create_task' => 'admin/meter_readers#create_task'
  get 'admin/meter_readers/:id/update_zones' => 'admin/meter_readers#update_zones'
  get 'admin/reader_tasks/:meter_reader_id' => 'admin/tasks#meter_reader_tasks'
  get 'admin/reader_tasks_since/:meter_reader_id/:since' => 'admin/tasks#meter_reader_tasks_since'
  #get 'admin/meter_readers/new_task' => 'admin/meter_readers#new_task'

  get 'admin/meter_readings/report/today' => 'admin/meter_readings#today', as: 'report/today'
  get 'admin/meter_readings/report/today/faulty' => 'admin/meter_readings#faulty_unclear', as: 'report/today/faulty'
  get 'admin/meter_readings/report/today/irregular' => 'admin/meter_readings#today_irregular', as: 'report_today_irregular'
  get 'admin/meter_readings/report/monthly/skipped' => 'admin/meter_readings#skipped_meters', as: 'report_monthly_skipped'
  get 'admin/meter_readings/report/monthly_performance' => 'admin/meter_readings#reader_performance', as: 'report_monthly_performance'

  post 'admin/meter_readers/auth' => 'admin/meter_readers#auth'
  get 'admin/town/zones' => 'admin/towns#zones'
  get 'admin/zones/:route_id/customers' => 'admin/zones#customers'
  get 'admin/customers/:customer_id/details' => 'admin/customers#details'
  get 'admin/meter/:customer_id' => 'admin/meters#customer'
  get 'admin/meter_reading/:meter_id' => 'admin/meter_readings#meter_reading'
  get 'admin/billing_period/:billing_period_id' => 'admin/billing_periods#billing_period'
  get 'admin/zones/:zone_id/routes' => 'admin/zones#routes'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
