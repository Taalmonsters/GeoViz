module GeoViz
  class DocumentsController < ApplicationController
    before_action :set_document
    before_action :set_group
    
    def entity
      if @document && params.has_key?(:entity_id)
        @entity_id = params[:entity_id].to_i
        @data = {}
        @group.metadata_keys.each do |metadata_key|
          @data[metadata_key.name] = metadata_key.metadatum_values.for_entity(@entity_id).for_document(@document).first.value.content
        end
        @data = map_to_geonames(@data)
        @marker = get_marker(@data)
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
    
  end
end