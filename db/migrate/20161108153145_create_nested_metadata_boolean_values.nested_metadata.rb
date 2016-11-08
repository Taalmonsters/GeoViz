# This migration comes from nested_metadata (originally 20161014165711)
class CreateNestedMetadataBooleanValues < ActiveRecord::Migration
  def change
    create_table :nested_metadata_boolean_values do |t|
      t.boolean :content

      t.timestamps null: false
    end
  end
end
