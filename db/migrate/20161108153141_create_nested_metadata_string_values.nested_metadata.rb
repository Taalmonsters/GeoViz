# This migration comes from nested_metadata (originally 20161014165426)
class CreateNestedMetadataStringValues < ActiveRecord::Migration
  def change
    create_table :nested_metadata_string_values do |t|
      t.text :content

      t.timestamps null: false
    end
  end
end
