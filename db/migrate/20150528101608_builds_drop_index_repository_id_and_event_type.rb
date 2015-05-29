class BuildsDropIndexRepositoryIdAndEventType < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_event_type"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_event_type ON builds (repository_id, event_type)"
  end
end
