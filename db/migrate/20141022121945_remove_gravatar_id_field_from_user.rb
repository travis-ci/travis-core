class RemoveGravatarIdFieldFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :gravatar_id
  end

  def down
    add_column    :users, :gravatar_id, :string
  end
end
