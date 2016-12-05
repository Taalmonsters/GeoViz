module GeoViz
  class EntityMentionsController < NestedMetadata::ApplicationController
    respond_to :js
    
    before_action :set_metadata_group
    before_action :set_document
    before_action :set_entity_mention
    
    def destroy
      if @is_annotator
        if @entity_mention
          id = @entity_mention.id
          @entity_mention.destroy
        end
        render "nested_metadata/documents/metadata_groups/show"
      else
        unauthorized_request
        redirect_to :controller => 'documents', :action => 'index'
      end
    end
    
    def edit
      unless @is_annotator
        unauthorized_request
        redirect_to :controller => 'documents', :action => 'index'
      end
    end
    
    private
    
    def set_entity_mention
      @entity_mention = NestedMetadata::EntityMention.find(params[:id].to_i) if params.has_key?(:id)
    end
    
  end
end