class BuildsAddIndexEventType < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_event_type ON builds (event_type)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_event_type"
  end
end

