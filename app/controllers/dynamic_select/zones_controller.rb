module DynamicSelect

  class ZonesController < ApplicationController
    respond_to :json

    def index
      @zones = Zone.where(:town_id => params[:town_id])
      respond_with(@zones)
    end

    def zones_routes
      @routes = Route.where(:zone_id=>params[:zone_id])
      respond_with(@routes)
    end
  end

end