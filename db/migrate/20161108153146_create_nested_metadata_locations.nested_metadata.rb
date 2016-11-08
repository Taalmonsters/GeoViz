# This migration comes from nested_metadata (originally 20161014165810)
class CreateNestedMetadataLocations < ActiveRecord::Migration
  def change
    create_table :nested_metadata_locations do |t|
      t.float :latitude
      t.float :longitude
      t.string :content
      t.string :toponym
      t.string :country
      t.integer :geonames_id, limit: 8

      t.timestamps null: false
    end
  end
end
