class AddOwnerTypeAndOwnerIdIndexesToRepositories < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX IF EXISTS index_repositories_on_owner_type"
    execute "DROP INDEX IF EXISTS index_repositories_on_owner_id"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_owner_type ON repositories(owner_type)"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_owner_id ON repositories(owner_id)"
  end

  def down
    execute "DROP INDEX IF EXISTS index_repositories_on_owner_type"
    execute "DROP INDEX IF EXISTS index_repositories_on_owner_id"
  end
end
