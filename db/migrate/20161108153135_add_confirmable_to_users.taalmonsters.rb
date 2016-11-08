# This migration comes from taalmonsters (originally 20161013130852)
class AddConfirmableToUsers < ActiveRecord::Migration
  def change
    add_column :taalmonsters_users, :confirmation_token, :string
    add_column :taalmonsters_users, :confirmed_at, :datetime
    add_column :taalmonsters_users, :confirmation_sent_at, :datetime
    add_column :taalmonsters_users, :unconfirmed_email, :string
  end
end
