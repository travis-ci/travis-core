class AddSlugIndexToRepositories < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_slug ON repositories((owner_name || '/' || name))"
  end

  def down
    execute "DROP INDEX IF EXISTS index_repositories_on_slug"
  end
end
