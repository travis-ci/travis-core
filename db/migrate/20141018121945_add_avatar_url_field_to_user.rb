class AddAvatarUrlFieldToUser < ActiveRecord::Migration
  def up
    add_column    :users, :avatar_url, :string
  end

  def down
    add_column    :users, :gravatar_id, :string
  end
end
