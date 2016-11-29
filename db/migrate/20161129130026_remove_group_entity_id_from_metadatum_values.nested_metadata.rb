# This migration comes from nested_metadata (originally 20161128112750)
class RemoveGroupEntityIdFromMetadatumValues < ActiveRecord::Migration
  def change
    remove_column :nested_metadata_metadatum_values, :group_entity_id, :integer
  end
end
