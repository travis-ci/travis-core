class StarredRepositoriesAddIndexUserIdAndRepoId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX index_starred_repositories_on_user_id_and_repo_id ON starred_repositories (user_id, repo_id)"
  end

  def down
    execute "DROP INDEX index_starred_repositories_on_user_id_and_repo_id"
  end
end
