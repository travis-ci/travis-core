class AddGithubIdToUsers < ActiveRecord::Migration
  def change
    add_column :repositories, :github_id, :integer

    add_index :repositories, :github_id
  end
end
