module GeoViz
  class PlacenamesController < Taalmonsters::ApplicationController
    
    def geocode
      @response = nil
      if params.has_key?(:q)
        @location_query = params[:q]
        @response = Taalmonsters::Geonames::Client.search(geocode_params(params))
      elsif params.has_key?(:lat) && params.has_key?(:lng)
        @location_query = "#{params[:lat]},#{params[:lng]}"
        @response = Taalmonsters::Geonames::Client.find_nearby_place_name(find_nearby_params(params))
      end
      @target = params[:target] if params.has_key?(:target)
      if @response && @response[0]
        @marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
        @marker.set_coordinates(@response[0]["lat"].to_f,@response[0]["lng"].to_f)
        @marker.label = @response[0]["toponymName"]
        @marker.letter = @marker.label[0]
        @marker.color = "13986D"
        @marker.infowindow = "<div>#{@response[0]["toponymName"]}</div>"
        @marker.draggable = true
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