# This migration comes from source_documents (originally 20161026103317)
class CreateSourceDocumentsDocumentLocks < ActiveRecord::Migration
  def change
    create_table :source_documents_document_locks do |t|
      t.integer :source_document_id
      t.string  :source_document_type

      t.timestamps null: false
    end
    add_index :source_documents_document_locks, [:source_document_id, :source_document_type], :name => 'locked_documents'
  end
end
