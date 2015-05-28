class BuildsAddIndexState < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_state ON builds (state)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_state"
  end
end
