module GeoViz
  class PlacenamesController < ApplicationController
    
    def geocode
      @response = nil
      if params.has_key?(:q)
        @location_query = params[:q]
        @response = Taalmonsters::Geonames::Client.search(geocode_params(params))
      elsif params.has_key?(:lat) && params.has_key?(:lng)
        @location_query = "#{params[:lat]},#{params[:lng]}"
        @response = Taalmonsters::Geonames::Client.find_nearby_place_name(find_nearby_params(params))
      end
      if @response && @response[0]
        @marker = get_marker(@response[0])
      end
      respond_to do |format|
        format.js
      end
    end
    
    def infowindow
      entity_mentions = NestedMetadata::EntityMention.includes(:source_document).at_latitude([params[:lat],"#{params[:lat].to_f}"]).includes(:source_document, :name, :country) & NestedMetadata::EntityMention.includes(:source_document).at_longitude([params[:lng],"#{params[:lng].to_f}"]).includes(:source_document, :name, :country)
      names = entity_mentions.map{|p| p.name.content.titleize }.uniq.join('/')
      extracts = entity_mentions.map{|entity_mention| entity_mention.source_document.document }
      respond_to do |format|
        format.json { render :json => {
          'html' => render_to_string(partial: "geo_viz/placenames/infowindow.html.erb", locals: {
            name: names,
            extracts: extracts,
            locations: entity_mentions.map{|entity_mention| entity_mention.siblings }.flatten.uniq.select{|entity_mention| entity_mention.latitude && entity_mention.longitude }.group_by{|entity_mention| [entity_mention.latitude.content.to_f, entity_mention.longitude.content.to_f] }
          }, layout: false) }
        }
      end
    end
    
    private
    
    def geocode_params(params)
      params = params.slice(:q)
      params["maxRows"] = 10
      return params
    end
    
    def find_nearby_params(params)
      params.slice(:lat, :lng)
    end
    
  end
end