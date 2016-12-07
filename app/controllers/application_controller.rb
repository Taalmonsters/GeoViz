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
    if @document
      @locations = @document.grouped_locations
    elsif @filters.keys.any?
      @locations = @all_documents.grouped_locations
    else
      @locations = (Extract.locations_in_group(NestedMetadata::MetadataGroup.with_name("GeoParser").with_keys.first) + Extract.locations_in_group(NestedMetadata::MetadataGroup.with_name("Annotations").with_keys.first)).flatten.select{|loc| !loc.latitude_str.blank? && !loc.longitude_str.blank? }.group_by do |loc|
        [loc.latitude_str.to_f, loc.longitude_str.to_f]
      end
    end
  end
end
