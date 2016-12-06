module GeoViz
  module ApplicationHelper
    
    def get_marker_color(group_name)
      colors = marker_colors
      return colors.has_key?(group_name) ? colors[group_name] : "17aed4"
    end
    
    def get_marker(data)
      name = data.has_key?("name") ? data["name"] : data["toponymName"]
      lat = data.has_key?("latitude") ? data["latitude"] : data["lat"]
      lng = data.has_key?("longitude") ? data["longitude"] : data["lng"]
      marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
      marker.set_coordinates(lat.to_f,lng.to_f)
      marker.label = name
      marker.title = "New"
      marker.letter = name[0]
      marker.country = data["countryCode"]
      marker.population = data["pop"].to_i
      marker.gazetteer = "geonames"
      marker.gazref = data["geonameId"]
      marker.type = data["fcode"]
      marker.color = "17aed4"
      marker.infowindow = "<span class='loading'></span>"
      marker.draggable = true
      return marker
    end
    
    def locations_to_map(locations)
      map = Taalmonsters::Maps::Google::SimpleMap.new
      locations.each do |coordinates, entity_mentions|
        marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
        marker.set_coordinates(coordinates[0],coordinates[1])
        names = entity_mentions.map{|p| p.name.content.titleize }.uniq.join('/')
        groups = entity_mentions.map{|p| p.metadata_group.name }.uniq.sort.join(', ')
        marker.color = get_marker_color(groups)
        if names
          marker.label = names
          marker.title = groups
          marker.letter = names[0]
          marker.infowindow = "<span class='loading'></span>"
        end
        map.add_marker(marker)
      end
      return map
    end
    
    def marker_colors
      {
        "GeoParser" => "DE4D60"
      }
    end
    
  end
end
