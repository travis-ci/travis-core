class UsersAddFirstLoggedInAt < ActiveRecord::Migration
  def change
    add_column :users, :first_logged_in_at, :datetime
  end
end
