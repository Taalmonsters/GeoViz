# This migration comes from nested_metadata (originally 20161014162700)
class CreateNestedMetadataMetadataKeys < ActiveRecord::Migration
  def change
    create_table :nested_metadata_metadata_keys do |t|
      t.string :name
      t.references :metadata_group, index: true, foreign_key: true
      t.integer :preferred_value_type, null: false, default: 5
      t.boolean :editable, null: false, default: true
      t.boolean :filterable, null: false, default: false
      t.integer :filter_type, null: false, default: 0
      t.integer :sort_order, null: false, default: 0

      t.timestamps null: false
    end
  end
end
