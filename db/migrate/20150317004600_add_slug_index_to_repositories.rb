class AddSlugIndexToRepositories < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_slug ON repositories USING gin((owner_name || '/' || name) gin_trgm_ops)"
  end

  def down
    execute "DROP INDEX IF EXISTS index_repositories_on_slug"
  end
end
