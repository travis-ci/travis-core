class RepositoriesAddIndexName < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_name ON repositories(name)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_repositories_on_name"
  end
end
