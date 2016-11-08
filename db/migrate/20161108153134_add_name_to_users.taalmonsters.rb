# This migration comes from taalmonsters (originally 20161013130850)
class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :taalmonsters_users, :name, :string
  end
end
