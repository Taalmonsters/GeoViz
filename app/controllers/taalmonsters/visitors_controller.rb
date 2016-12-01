module Taalmonsters
  class VisitorsController < NestedMetadata::ApplicationController
    before_action :check_user_role
    before_action :set_tab
    before_action :set_filters
    before_action :set_source_document_class
    before_action :set_documents
    before_action :set_locations, :only => [:locations]
    
    def index
    end
    
    def locations
      @map = Taalmonsters::Maps::Google::SimpleMap.new
      @locations.each do |coordinates, places|
        marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
        marker.set_coordinates(coordinates[0],coordinates[1])
        marker.color = "98598E"
        if places[0]["name"]
          marker.label = places[0]["name"]
          marker.letter = marker.label[0]
          marker.infowindow = "<div>#{places[0]["name"]} (#{places.count})</div>"
        end
        @map.add_marker(marker)
      end
      respond_to do |format|
        format.json {
          render :json => @map.markers
        }
      end
    end
    
    private
    
    def set_locations
      latitude_keys = NestedMetadata::MetadataKey.with_name("latitude").all.map{|key| key.id }
      longitude_keys = NestedMetadata::MetadataKey.with_name("longitude").all.map{|key| key.id }
      @locations = NestedMetadata::EntityMention.with_metadatum_values.has_type("location").select("(SELECT mv1.content FROM #{NestedMetadata::MetadatumValue.table_name} AS mv1 WHERE mv1.metadata_key_id IN (#{latitude_keys.join(",")}) AND mv1.entity_mention_id = #{NestedMetadata::EntityMention.table_name}.id) AS latitude, (SELECT mv2.content FROM #{NestedMetadata::MetadatumValue.table_name} AS mv2 WHERE mv2.metadata_key_id IN (#{longitude_keys.join(",")}) AND mv2.entity_mention_id = #{NestedMetadata::EntityMention.table_name}.id) AS longitude, #{NestedMetadata::EntityMention.table_name}.*").group_by do |location|
        [location.latitude.to_f, location.longitude.to_f]
      end
    end
    
  end
end