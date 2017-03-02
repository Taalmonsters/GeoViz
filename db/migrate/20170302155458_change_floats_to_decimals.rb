class ChangeFloatsToDecimals < ActiveRecord::Migration
  def change
    change_column :nested_metadata_float_values, :content, :decimal, :precision => 16, :scale => 6
    change_column :nested_metadata_locations, :latitude, :decimal, :precision => 9, :scale => 6
    change_column :nested_metadata_locations, :longitude, :decimal, :precision => 9, :scale => 6
  end
end
