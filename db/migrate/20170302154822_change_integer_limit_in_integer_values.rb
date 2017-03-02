class ChangeIntegerLimitInIntegerValues < ActiveRecord::Migration
  def change
    change_column :nested_metadata_integer_values, :content, :integer, limit: 8
  end
end
