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
      @word_id = params.has_key?(:word_id) ? params[:word_id].to_i : nil
      unless @is_annotator
        unauthorized_request
        redirect_to :controller => 'documents', :action => 'index'
      end
    end
    
    def new
      if @is_annotator
        @entity_mention = @source_document.entity_mentions.new
        @entity_mention.metadata_group = @group
        @group.metadata_keys.order(:sort_order).each do |key|
          key_sym = key.name.to_sym
          metadatum_value = @entity_mention.metadatum_values.new
          metadatum_value.metadata_key = key
          metadatum_value.source_document = @source_document
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