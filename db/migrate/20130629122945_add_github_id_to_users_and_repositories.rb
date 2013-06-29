class AddGithubIdToUsersAndRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :github_id, :integer
    add_column :users, :github_id, :integer

    add_index :repositories, :github_id
    add_index :users, :github_id
  end
end
