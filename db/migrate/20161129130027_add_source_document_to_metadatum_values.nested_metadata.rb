# This migration comes from nested_metadata (originally 20161128182340)
class AddSourceDocumentToMetadatumValues < ActiveRecord::Migration
  def change
    add_reference :nested_metadata_metadatum_values, :source_document, index: true
  end
end
