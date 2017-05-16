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
      @update_gn = false
      if params.has_key?(:q) || (params.has_key?(:dbpedia) && params[:update_gn].eql?("true"))
        @update_gn = true
        @gn_location_query = params.has_key?(:dbpedia) ? params[:dbpedia] : params[:q]
        @gn_response = Taalmonsters::Geonames::Client.search(geocode_params(params)).map{|r| get_marker(r) }
        @dbp_location_query = params.has_key?(:dbpedia) ? params[:dbpedia] : @gn_response.any? ? @gn_response.sort_by{|gn| gn.label.length }.first.label : @gn_location_query
        @dbp_response = searchDbPedia(@dbp_location_query).map{|r| get_dbpedia_marker(r) }
        @marker = @gn_response && @gn_response.any? ? @gn_response[0] : @dbp_response && @dbp_response.any? ? @dbp_response[0] : nil
      elsif params.has_key?(:lat) && params.has_key?(:lng)
        @marker = nil
        @location_query = "#{params[:lat]},#{params[:lng]}"
        @gn_response = Taalmonsters::Geonames::Client.find_nearby_place_name(find_nearby_params(params)).map{|r| get_marker(r) }
        if @gn_response && @gn_response.any?
          @marker = @gn_response[0]
          if params[:update_dbp].eql?("true")
            @dbp_location_query = @gn_response.sort_by{|gn| gn.label.length }.first.label
            @dbp_response = searchDbPedia(@dbp_location_query).map{|r| get_dbpedia_marker(r) }
          end
        end
      elsif params.has_key?(:dbpedia)
        @dbp_location_query = params[:dbpedia]
        @dbp_response = searchDbPedia(@dbp_location_query).map{|r| get_dbpedia_marker(r) }
      end
      respond_to do |format|
        format.js
      end
    end
    
    def infowindow
      map_id = params[:map]
      entity_mentions = NestedMetadata::EntityMention.includes(:source_document).at_latitude([params[:lat],"#{params[:lat].to_f}"]).includes(:source_document, :name, :dbpedia_id) & NestedMetadata::EntityMention.includes(:source_document).at_longitude([params[:lng],"#{params[:lng].to_f}"]).includes(:source_document, :name, :dbpedia_id)
      ids = entity_mentions.select{|em| !em.dbpedia_id.blank? }.map{|em| em.dbpedia_id.content.to_i }.uniq
      names = entity_mentions.map{|em| em.name.content.titleize }.uniq
      desc = ids.any? ? get_dbpedia_descriptions(ids) : searchDbPedia(names.first)
      if map_id.eql?("extract-map")
        respond_to do |format|
          format.json { render :json => {
            'html' => render_to_string(partial: "geo_viz/placenames/infowindow.html.erb", locals: {
              names: names,
              description: desc.any? ? desc.first : nil,
              extracts: nil
            }, layout: false) }
          }
        end
      else
        extracts = entity_mentions.map{|entity_mention| entity_mention.source_document.document }.uniq
        respond_to do |format|
          format.json { render :json => {
            'html' => render_to_string(partial: "geo_viz/placenames/infowindow.html.erb", locals: {
              names: names,
              description: desc.any? ? desc.first : nil,
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
      params["maxRows"] = 50
      return params
    end
    
    def find_nearby_params(params)
      params.slice(:lat, :lng)
    end
    
  end
end