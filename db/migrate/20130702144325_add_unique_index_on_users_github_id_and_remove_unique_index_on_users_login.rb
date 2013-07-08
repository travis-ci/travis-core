class AddUniqueIndexOnUsersGithubIdAndRemoveUniqueIndexOnUsersLogin < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX index_users_on_login"
    execute "CREATE INDEX CONCURRENTLY index_users_on_login ON users(login)"
    execute "DROP INDEX index_users_on_github_id"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_users_on_github_id ON users(github_id)"
  end

  def down
    execute "DROP INDEX index_users_on_github_id"
    execute "CREATE INDEX CONCURRENTLY index_users_on_github_id ON users(github_id)"
    execute "DROP INDEX index_users_on_login"
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_users_on_login ON users(login)"
  end
end
