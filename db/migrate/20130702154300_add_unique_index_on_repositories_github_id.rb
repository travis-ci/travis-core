class AddUniqueIndexOnRepositoriesGithubId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_repositories_on_github_id"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_repositories_on_github_id ON repositories(github_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_repositories_on_github_id"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_github_id ON repositories(github_id)"
  end
end
