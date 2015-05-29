class BuildsDropIndexRepositoryIdAndState < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_state"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_state ON builds (repository_id, state)"
  end
end
