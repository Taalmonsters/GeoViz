module GeoViz
  module ApplicationHelper
    
    def get_marker(data)
      name = data.has_key?("name") ? data["name"] : data["toponymName"]
      lat = data.has_key?("latitude") ? data["latitude"] : data["lat"]
      lng = data.has_key?("longitude") ? data["longitude"] : data["lng"]
      marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
      marker.set_coordinates(lat.to_f,lng.to_f)
      marker.label = name
      marker.letter = name[0]
      marker.color = "13986D"
      marker.infowindow = "<div>#{name}</div>"
      marker.draggable = true
      return marker
    end
    
  end
end