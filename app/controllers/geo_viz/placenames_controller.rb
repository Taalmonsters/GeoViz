module GeoViz
  class PlacenamesController < NestedMetadata::ApplicationController
    include GeoViz::ApplicationHelper
    before_action :set_tab, :only => [:locations]
    before_action :set_document, :only => [:locations]
    before_action :set_filters, :only => [:locations]
    before_action :set_source_document_class, :only => [:locations]
    before_action :set_documents, :only => [:locations]
    before_action :set_locations, :only => [:locations]
    before_action :load_map, :only => [:locations]
    
    def geocode
      @response = nil
      if params.has_key?(:q)
        @location_query = params[:q]
        @response = Taalmonsters::Geonames::Client.search(geocode_params(params)).map{|r| get_marker(r) }
      elsif params.has_key?(:lat) && params.has_key?(:lng)
        @location_query = "#{params[:lat]},#{params[:lng]}"
        @response = Taalmonsters::Geonames::Client.find_nearby_place_name(find_nearby_params(params)).map{|r| get_marker(r) }
      end
      if @response && @response[0]
        @marker = @response[0]
      end
      respond_to do |format|
        format.js
      end
    end
    
    def infowindow
      map_id = params[:map]
      entity_mentions = NestedMetadata::EntityMention.includes(:source_document).at_latitude([params[:lat],"#{params[:lat].to_f}"]).includes(:source_document, :name, :country) & NestedMetadata::EntityMention.includes(:source_document).at_longitude([params[:lng],"#{params[:lng].to_f}"]).includes(:source_document, :name, :country)
      names = entity_mentions.map{|p| p.name.content.titleize }.uniq.join('/')
      extracts = entity_mentions.map{|entity_mention| entity_mention.source_document.document }
      if map_id.eql?("extract-map")
        respond_to do |format|
          format.json { render :json => {
            'html' => render_to_string(partial: "geo_viz/placenames/infowindow.html.erb", locals: {
              name: names,
              extracts: nil
            }, layout: false) }
          }
        end
      else
        respond_to do |format|
          format.json { render :json => {
            'html' => render_to_string(partial: "geo_viz/placenames/infowindow.html.erb", locals: {
              name: names,
              extracts: extracts
            }, layout: false) }
          }
        end
      end

    end
    
    def locations
      respond_to do |format|
        format.json {
          render :json => { :markers => @map.markers, :historical_latitude => @document ? @document.historical_latitude : nil, :historical_longitude => @document ? @document.historical_longitude : nil }
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