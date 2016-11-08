# This migration comes from nested_metadata (originally 20161014165650)
class CreateNestedMetadataDateValues < ActiveRecord::Migration
  def change
    create_table :nested_metadata_date_values do |t|
      t.date :content

      t.timestamps null: false
    end
  end
end
