class AddGithubLanguageToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :github_language, :string
  end
end
