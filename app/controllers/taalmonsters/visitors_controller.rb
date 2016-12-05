module Taalmonsters
  class VisitorsController < NestedMetadata::ApplicationController
    before_action :check_user_role
    before_action :set_tab
    before_action :set_filters
    before_action :set_source_document_class
    before_action :set_documents
    
  end
end