# This migration comes from nested_metadata (originally 20161015141319)
class CreateNestedMetadataMetadatumValues < ActiveRecord::Migration
  def change
    create_table :nested_metadata_metadatum_values do |t|
      t.integer :metadata_key_id
      t.integer :value_id
      t.string :value_type
      t.string :content
      t.integer :group_entity_id, null: false, default: 0

      t.timestamps null: false
    end
  end
end
