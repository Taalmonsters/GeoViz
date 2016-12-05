class ApplicationController < Taalmonsters::ApplicationController
  include GeoViz::ApplicationHelper
    
  protected
  
  def load_map
    if @locations
      @map = Taalmonsters::Maps::Google::SimpleMap.new
      @locations.each do |coordinates, entity_mentions|
        marker = Taalmonsters::Maps::Google::SimpleMapMarker.new
        marker.set_coordinates(coordinates[0],coordinates[1])
        names = entity_mentions.map{|p| p.name.content.titleize }.uniq.join('/')
        groups = entity_mentions.map{|p| p.metadata_group.name }.uniq.sort.join(', ')
        marker.color = get_marker_color(groups)
        # extracts = @extracts_with_locations.keys.select{|extract| !(@extracts_with_locations[extract] & entity_mentions).empty? }
        if names
          marker.label = names
          marker.title = groups
          marker.letter = names[0]
          marker.infowindow = "<span class='loading'></span>"
        end
        @map.add_marker(marker)
      end
    end
  end
    
  def set_document
    @document = Extract.find(params[:id].to_i) if params.has_key?(:id)
  end
  
  def set_group
    @group = NestedMetadata::MetadataGroup.with_name("Annotations").with_keys.first
  end
    
  def set_locations
    @extracts_with_locations = @document ? { @document => @document.locations } : @all_documents.locations
    @locations = @extracts_with_locations.values.flatten
    .select{|entity_mention| entity_mention.latitude && entity_mention.latitude.content && entity_mention.longitude && entity_mention.longitude.content }
    .group_by{|entity_mention| [entity_mention.latitude.content.to_f, entity_mention.longitude.content.to_f] }
  end
end
