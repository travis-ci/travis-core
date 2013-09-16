class AddUniqueIndexOnRepositoryGithubId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX index_repositories_on_github_id"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_repositories_on_github_id ON repositories(github_id)"
  end

  def down
  end
end
