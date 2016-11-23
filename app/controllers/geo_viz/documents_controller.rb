module GeoViz
  class DocumentsController < ApplicationController
    before_action :set_document
    
    def entity
      if @document && params.has_key?(:entity_id)
        @data = {}
        NestedMetadata::MetadataGroup.with_name("Annotations").with_keys.first.metadata_keys.each do |metadata_key|
          @data[metadata_key.name] = metadata_key.metadatum_values.for_entity(params[:entity_id].to_i).for_document(@document).first.value.content
        end
        @data = map_to_geonames(@data)
        @marker = get_marker(@data)
        puts @data.to_json
        puts @marker.to_json
      end
    end
    
    private
    
    def map_to_geonames(data)
      translations = {
        "latitude" => "lat",
        "longitude" => "lng",
        "name" => "toponymName",
        "gazref" => "geonameId",
        "country" => "countryCode",
        "type" => "fcode"
      }
      hash = {}
      data.each do |key, value|
        if translations.has_key?(key)
          hash[translations[key]] = value
        else
          hash[key] = value
        end
      end
      return hash
    end
    
    def set_document
      @document = Extract.find(params[:id].to_i) if params.has_key?(:id)
    end
    
  end
end