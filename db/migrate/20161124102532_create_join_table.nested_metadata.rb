# This migration comes from nested_metadata (originally 20161014163233)
class CreateJoinTable < ActiveRecord::Migration
  def change
    create_table :nested_metadata_source_documents do |t|
      t.integer :metadatum_value_id
      t.integer :source_document_id
      t.string  :source_document_type
      t.timestamps
    end
    add_index :nested_metadata_source_documents, [:source_document_id, :source_document_type], :name => 'index_documents_types'
    add_index :nested_metadata_source_documents, [:source_document_id, :metadatum_value_id], :name => 'index_documents_values'
    add_index :nested_metadata_source_documents, [:metadatum_value_id, :source_document_id], :name => 'index_values_documents'
  end
end
