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
    
    def new
      if @is_annotator
        @entity_mention = @source_document.entity_mentions.has_group(@group).create
        @group.metadata_keys.order(:sort_order).each do |key|
          key_sym = key.name.to_sym
          metadatum_value = @entity_mention.metadatum_values.has_key(key).has_source_document(@source_document).create
        end
      else
        unauthorized_request
        redirect_to :controller => 'documents', :action => 'index'
      end
    end
    
    private
    
    def set_entity_mention
      @entity_mention = params.has_key?(:id) ? NestedMetadata::EntityMention.find(params[:id].to_i) : NestedMetadata::EntityMention.new
    end
    
  end
end