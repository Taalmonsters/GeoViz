module NestedMetadata
  class Documents::SourceDocumentsController < NestedMetadata::ApplicationController
    respond_to :js
    
    before_action :set_tab, :only => [:index]
    before_action :set_source_document, :except => [:index]
    before_action :set_source_document_class, :only => [:index]
    before_action :set_filters, :only => [:index]
    before_action :set_documents, :only => [:index]
    before_action :set_metadata_group, :only => [:show]
    before_action :set_locations, :only => [:show]
    
    def index
      @target = params.has_key?(:target) ? params[:target] : "#source-documents"
    end
    
    def show
      @target = params.has_key?(:target) ? params[:target] : "#source-document"
    end
    
    private
    
    def set_source_document
      @source_document = NestedMetadata::SourceDocument.find(params[:id].to_i) if params.has_key?(:id)
      @document = @source_document.document
    end
    
    def source_document_params
      params.require(:source_document).permit(:source_document => [:name])
    end
    
  end
end