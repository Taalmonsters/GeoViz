# This migration comes from nested_metadata (originally 20161014162627)
class CreateNestedMetadataMetadataGroups < ActiveRecord::Migration
  def change
    create_table :nested_metadata_metadata_groups do |t|
      t.string :name
      t.references :metadata_group, index: true
      t.boolean :group_keys_into_entity, null: false, default: false
      t.boolean :requires_attachment, null: false, default: false
      t.integer :attachment_type, null: false, default: 0
      t.string :attachment_extension
      t.boolean :editable_when_locked, null: false, default: false
      t.integer :sort_order, null: false, default: 0

      t.timestamps null: false
    end
  end
end
