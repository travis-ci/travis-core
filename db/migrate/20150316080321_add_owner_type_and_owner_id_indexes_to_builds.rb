class AddOwnerTypeAndOwnerIdIndexesToBuilds < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX IF EXISTS index_builds_on_owner_type"
    execute "DROP INDEX IF EXISTS index_builds_on_owner_id"
    execute "CREATE INDEX CONCURRENTLY index_builds_on_owner_type ON builds(owner_type)"
    execute "CREATE INDEX CONCURRENTLY index_builds_on_owner_id ON builds(owner_id)"
  end

  def down
    execute "DROP INDEX IF EXISTS index_builds_on_owner_type"
    execute "DROP INDEX IF EXISTS index_builds_on_owner_id"
  end
end
