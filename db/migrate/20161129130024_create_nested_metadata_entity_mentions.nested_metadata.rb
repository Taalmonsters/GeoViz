# This migration comes from nested_metadata (originally 20161128105227)
class CreateNestedMetadataEntityMentions < ActiveRecord::Migration
  def change
    create_table :nested_metadata_entity_mentions do |t|
      t.string :entity_type, index: true, null: false, default: "undefined"
      t.references :metadata_group, index: true, null: false
      t.references :source_document, index: true, null: false

      t.timestamps null: false
    end
  end
end
