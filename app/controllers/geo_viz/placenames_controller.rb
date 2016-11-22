module GeoViz
  class PlacenamesController < Taalmonsters::ApplicationController
    
    def geocode
      @response = nil
      if params.has_key?(:query)
        @response = Taalmonsters::Geonames::Client.geocode(params[:query], true)
      elsif params.has_key?(:latitude) && params.has_key?(:longitude)
        @response = Taalmonsters::Geonames::Client.find_nearby_place_name({ "lat" => params[:latitude], "lng" => params[:longitude] })
      end
      @target = params[:target] if params.has_key?(:target)
      if @response
        @marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
        @marker.set_coordinates(@response[0]["lat"].to_f,@response[0]["lng"].to_f)
        @marker.label = @response[0]["toponymName"]
        @marker.letter = @marker.label[0]
        @marker.color = "13986D"
        @marker.infowindow = "<div>#{@response[0]["toponymName"]}</div>"
        @marker.draggable = true
      end
    end
    
  end
end