# This migration comes from nested_metadata (originally 20161014165640)
class CreateNestedMetadataFloatValues < ActiveRecord::Migration
  def change
    create_table :nested_metadata_float_values do |t|
      # t.references :metadata_key, index: { name: 'index_nested_metadata_float_values' }, foreign_key: true
      t.float :content

      t.timestamps null: false
    end
  end
end
