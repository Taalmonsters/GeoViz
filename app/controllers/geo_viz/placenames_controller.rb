module GeoViz
  class PlacenamesController < ApplicationController
    
    def geocode
      @response = nil
      @entity_id = params[:entity_id].to_i if params.has_key?(:entity_id)
      if params.has_key?(:q)
        @location_query = params[:q]
        @response = Taalmonsters::Geonames::Client.search(geocode_params(params))
      elsif params.has_key?(:lat) && params.has_key?(:lng)
        @location_query = "#{params[:lat]},#{params[:lng]}"
        @response = Taalmonsters::Geonames::Client.find_nearby_place_name(find_nearby_params(params))
      end
      if @response && @response[0]
        @marker = get_marker(@response[0])
      end
    end
    
    private
    
    def geocode_params(params)
      params = params.slice(:q)
      params["maxRows"] = 10
      return params
    end
    
    def find_nearby_params(params)
      params.slice(:lat, :lng)
    end
    
  end
end