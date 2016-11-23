module Taalmonsters
  class VisitorsController < NestedMetadata::ApplicationController
    before_action :check_user_role
    before_action :set_tab
    before_action :set_filters
    before_action :set_documents
    before_action :set_locations
    
    def index
    end
    
    private
    
    def set_locations
      @locations = NestedMetadata::MetadatumValue.key("latitude")
      .joins(:metadata_group, :source_documents)
      .group("nested_metadata_metadata_groups.name", "nested_metadata_metadatum_values.group_entity_id")
      .count
      .keys.map do |entity|
        NestedMetadata::MetadatumValue.joins(:source_documents).for_documents(@documents)
        .key(["name", "latitude", "longitude", "gazetteer", "gazref"])
        .includes(:metadata_group)
        .in_group(entity[0])
        .for_entity(entity[1]).all.map do |metadatum_value|
          [ metadatum_value.metadata_key.name, metadatum_value.content ]
        end.to_h
      end.group_by{|hash| [hash["latitude"], hash["longitude"]] }
    end
    
  end
end