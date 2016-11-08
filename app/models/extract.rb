class Extract < ActiveRecord::Base
  include NestedMetadata::Document
  include BlacklabRails::BlacklabDocument
  include SourceDocuments::Base
end
