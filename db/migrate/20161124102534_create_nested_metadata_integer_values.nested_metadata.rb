# This migration comes from nested_metadata (originally 20161014165625)
class CreateNestedMetadataIntegerValues < ActiveRecord::Migration
  def change
    create_table :nested_metadata_integer_values do |t|
      t.integer :content

      t.timestamps null: false
    end
  end
end
