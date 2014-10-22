class AddAvatarUrlFieldToUser < ActiveRecord::Migration
  def up
    add_column    :users, :avatar_url, :string
  end

  def down
    remove_column :users, :avatar_url
  end
end
