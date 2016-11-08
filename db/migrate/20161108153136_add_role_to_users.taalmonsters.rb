# This migration comes from taalmonsters (originally 20161013130857)
class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :taalmonsters_users, :role, :integer
  end
end
