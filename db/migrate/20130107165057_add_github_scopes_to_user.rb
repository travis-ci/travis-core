class AddGithubScopesToUser < ActiveRecord::Migration
  def change
    add_column :users, :github_scopes, :text
  end
end
