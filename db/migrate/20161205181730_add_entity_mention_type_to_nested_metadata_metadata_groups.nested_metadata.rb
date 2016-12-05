# This migration comes from nested_metadata (originally 20161205181525)
class AddEntityMentionTypeToNestedMetadataMetadataGroups < ActiveRecord::Migration
  def change
    add_column :nested_metadata_metadata_groups, :entity_mention_type, :string, :null => false, :default => "location"
  end
end
