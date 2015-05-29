class BuildsAddIndexName < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_name ON builds (name)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_name"
  end
end
