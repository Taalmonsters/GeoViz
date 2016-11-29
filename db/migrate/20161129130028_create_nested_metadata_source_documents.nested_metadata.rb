# This migration comes from nested_metadata (originally 20161128182719)
class CreateNestedMetadataSourceDocuments < ActiveRecord::Migration
  def change
    create_table :nested_metadata_source_documents do |t|
      t.integer :source_document_id, index: true, null: false
      t.string :source_document_type, index: true, null: false

      t.timestamps null: false
    end
  end
end
