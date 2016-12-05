module Taalmonsters
  class VisitorsController < NestedMetadata::ApplicationController
    before_action :check_user_role
    before_action :set_tab
    before_action :set_filters
    before_action :set_source_document_class
    before_action :set_documents
    before_action :set_locations, :only => [:locations]
    before_action :load_map, :only => [:locations]
    
    def locations
      respond_to do |format|
        format.json {
          render :json => { :markers => @map.markers, :opt => marker_colors.map{|group, color| ["#{group}","##{color}"] }.to_h }
        }
      end
    end
    
  end
end