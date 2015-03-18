class AddActiveIndexToRepository < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX IF EXISTS index_repositories_on_active"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_active ON repositories(active)"
  end

  def down
    execute "DROP INDEX IF EXISTS index_repositories_on_active"
  end
end
