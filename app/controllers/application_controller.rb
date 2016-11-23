class ApplicationController < Taalmonsters::ApplicationController
  include GeoViz::ApplicationHelper
  before_action :set_document
  before_action :set_group
    
  protected
    
  def set_document
    @document = Extract.find(params[:id].to_i) if params.has_key?(:id)
  end
  
  def set_group
    @group = NestedMetadata::MetadataGroup.with_name("Annotations").with_keys.first
  end
end
