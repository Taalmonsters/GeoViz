module NestedMetadata
  module Metadata
    class MetadataKeysController < NestedMetadata::ApplicationController
      before_action :check_user_role
      
      def create
        if @is_admin && params.has_key?(:metadata_group_id)
          @group = NestedMetadata::MetadataGroup.find(params[:metadata_group_id].to_i)
          @key = @group.metadata_keys.create(key_params)
          @group.entity_mentions.each do |entity_mention|
            entity_mention.metadatum_values.create(:metadata_key => @key, :source_document => entity_mention.source_document)
          end
          redirect_to controller: 'metadata', action: 'index', group: @group.name, key: @key.name, key_settings: true
        else
          unauthorized_request
          redirect_to controller: 'metadata', action: 'index', group: @group.name
        end
      end
      
      def destroy
        if @is_admin
          @key = NestedMetadata::MetadataKey.find(params[:id].to_i)
          @group = @key.metadata_group
          @key.destroy
        else
          unauthorized_request
        end
        redirect_to controller: 'metadata', action: 'index', group: @group.name
      end
      
      def new
        if @is_admin && params.has_key?(:metadata_group_id)
          @group = NestedMetadata::MetadataGroup.find(params[:metadata_group_id].to_i)
          @key = @group.metadata_keys.new
          @key.name = "New metadata key"
          @key_settings = true
        else
          unauthorized_request
        end
      end

      def translate
        @key = NestedMetadata::MetadataKey.find(params[:metadata_key_id].to_i) if params.has_key?(:metadata_key_id)
        @sort = params.has_key?(:sort) ? params[:sort] : "value"
        @order = params.has_key?(:order) ? params[:order] : "asc"
        if @is_admin && @key && params.has_key?(:value) && params.has_key?(:value_type) && params.has_key?(:new_value) && !params[:new_value].blank?
          @key.metadatum_values.where("content = ? AND value_type = ?", params[:value], params[:value_type]).each do |metadatum_value|
            metadatum_value.update_attribute(:content, params[:new_value])
            metadatum_value.set_typed_value
          end
        end
        redirect_to controller: 'metadata', action: 'index', group: @key.metadata_group.name, key: @key.name, page: @page, sort: @sort, order: @order
      end
      
      def update
        if @is_admin && params.has_key?(:id)
          @key = NestedMetadata::MetadataKey.find(params[:id].to_i)
          changed_to_location = !@key.preferred_value_type.eql?('location') && params[:metadata_key].has_key?(:preferred_value_type) && params[:metadata_key][:preferred_value_type].eql?("location")
          @key.update_attributes(key_params)
          if changed_to_location
            Thread.new do
              @key.metadatum_values.select{|metadatum_value| !metadatum_value.value || !metadatum_value.value.class.eql?(NestedMetadata::Location) }.each do |metadatum_value|
                metadatum_value.update_attribute(:value, NestedMetadata::Location.where(content: metadatum_value.content).first_or_create)
              end
            end
          end
          redirect_to controller: 'metadata', action: 'index', group: @key.metadata_group.name, key: @key.name, key_settings: true
        else
          unauthorized_request
          redirect_to controller: 'metadata', action: 'index'
        end
      end
      
      private
      
      def key_params
        params.require(:metadata_key).permit(:name, :sort_order, :preferred_value_type, :editable, :filterable, :filter_type, :metadata_group_id)
      end
      
    end
  end
end
