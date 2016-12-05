class AddTokenCountToExtracts < ActiveRecord::Migration
  def change
    add_column :extracts, :token_count, :integer
  end
end
