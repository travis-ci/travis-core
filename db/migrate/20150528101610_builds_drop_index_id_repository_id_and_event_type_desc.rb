class BuildsDropIndexIdRepositoryIdAndEventTypeDesc < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_builds_on_id_repository_id_and_event_type_desc"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_builds_on_id_repository_id_and_event_type_desc ON builds (id DESC, repository_id, event_type)"
  end
end
