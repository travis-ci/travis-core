class AddAvatarUrlFieldToUser < ActiveRecord::Migration
  def up
    add_column    :users, :avatar_url, :string
    remove_column :users, :gravatar_id
  end

  def down
    remove_column :users, :avatar_url
    add_column    :users, :gravatar_id, :string
  end
end
