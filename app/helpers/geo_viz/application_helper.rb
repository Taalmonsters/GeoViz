module GeoViz
  module ApplicationHelper

    def get_dbpedia_marker(data)
      name = data.label.to_s
      lat = data["lat"] ? data["lat"].to_s : "0"
      lng = data["long"] ? data["long"].to_s : "0"
      marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
      marker.set_coordinates(lat.to_f,lng.to_f)
      marker.label = name
      marker.title = "New"
      marker.letter = name[0]
      marker.gazetteer = "dbpedia"
      marker.gazref = data["id"].to_s
      marker.type = data["type"].to_s.sub('http://dbpedia.org/ontology/','')
      marker.color = "17aed4"
      marker.infowindow = data['desc'].to_s
      marker.draggable = true
      return marker
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
        names = entity_mentions.map{|p| p.respond_to?("name_str") ? p.name_str : p.name.content }.uniq.join('/')
        groups = entity_mentions.map do |p|
          if p.respond_to?("annotated_by_id")
            "User #{p.annotated_by_id}"
          elsif p.respond_to?("group_name")
            p.group_name
          elsif p.respond_to?("audits") && p.audits.any?
            "User #{p.audits.last.user.id}"
          else
            p.metadata_group.name
          end
        end.uniq.sort.join(', ')
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

    def searchDbPedia(query)
      return [] if query.blank?
      return Dbpedia.sparql.query("PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"+
        "PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>\n"+
        "PREFIX dbo: <http://dbpedia.org/ontology/>\n"+
        "PREFIX desc:<http://www.w3.org/2000/01/rdf-schema#>\n"+
        "\n"+
        "SELECT DISTINCT ?id (SAMPLE(?s) AS ?s) (SAMPLE(?label) AS ?label) (SAMPLE(?type) AS ?type) (SAMPLE(?desc) AS ?desc) (SAMPLE(?lat) AS ?lat) (SAMPLE(?lng) AS ?lng) WHERE {\n"+
        "    ?s a ?type .\n"+
        "    FILTER (?type = dbo:ArchitecturalStructure || ?type = dbo:CelestialBody || ?type = dbo:HistoricPlace || ?type = dbo:Monument || ?type = dbo:NaturalPlace || ?type = dbo:Park || ?type = dbo:PopulatedPlace).\n"+
        "    ?s dbo:wikiPageID ?id.\n"+
        "    ?s rdfs:label ?label.\n"+
        "    ?s desc:comment ?desc.\n"+
        "    OPTIONAL { ?s geo:lat ?lat. }\n"+
        "    OPTIONAL { ?s geo:long ?lng. }\n"+
        "    FILTER langMatches( lang(?label), \"EN\" ).\n"+
        "    FILTER (langMatches(lang(?desc),\"EN\")).\n"+
        "    ?label bif:contains \"'#{query}'\".\n"+
        "}\n"+
        "ORDER BY strlen(str(?label))\n"+
        "LIMIT 50")
    end

    def get_dbpedia_descriptions(ids = [])
      return [] unless ids.any?
      ids = '?id = '+ids.join(' || ?id = ')
      return Dbpedia.sparql.query("PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"+
          "PREFIX dbo: <http://dbpedia.org/ontology/>\n"+
          "PREFIX desc:<http://www.w3.org/2000/01/rdf-schema#>\n"+
          "\n"+
          "select distinct * where {\n"+
          "    ?s dbo:wikiPageID ?id.\n"+
          "    FILTER (#{ids}).\n"+
          "    ?s rdfs:label ?label.\n"+
          "    ?s desc:comment ?desc.\n"+
          "    FILTER langMatches( lang(?label),\"EN\" ).\n"+
          "    FILTER (langMatches(lang(?desc),\"EN\")).\n"+
          "}")
    end
    
  end
end
