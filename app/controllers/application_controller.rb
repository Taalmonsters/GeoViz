class ApplicationController < Taalmonsters::ApplicationController
  include GeoViz::ApplicationHelper
    
  protected
  
  def load_map
    if @locations
      @map = locations_to_map(@locations)
    end
  end
    
  def set_document
    @document = Extract.find(params[:id].to_i) if params.has_key?(:id)
  end
  
  def set_group
    @group = NestedMetadata::MetadataGroup.with_name("Annotations").with_keys.first
  end
    
  def set_locations
    @locations = @document ? @document.grouped_locations : @all_documents.grouped_locations
    # @locations = @extracts_with_locations.values.flatten
    # .select{|entity_mention| entity_mention.latitude && entity_mention.latitude.content && entity_mention.longitude && entity_mention.longitude.content }
    # .group_by{|entity_mention| [entity_mention.latitude.content.to_f, entity_mention.longitude.content.to_f] }
  end
end
