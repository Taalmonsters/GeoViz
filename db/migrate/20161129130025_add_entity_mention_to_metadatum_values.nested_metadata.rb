# This migration comes from nested_metadata (originally 20161128111356)
class AddEntityMentionToMetadatumValues < ActiveRecord::Migration
  def change
    add_reference :nested_metadata_metadatum_values, :entity_mention, index: true
  end
end
