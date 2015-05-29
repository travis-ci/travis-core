class BuildsDropIndexRepositoryIdAndEventTypeAndStateAndBranch < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_event_type_and_state_and_bran"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_event_type_and_state_and_bran ON builds (repository_id, event_type, state, branch)"
  end
end
