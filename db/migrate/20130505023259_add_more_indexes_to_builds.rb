class AddMoreIndexesToBuilds < ActiveRecord::Migration
  self.disable_ddl_transaction!
  def up
     execute <<-SQL
      CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_event_type_and_state_and_branch
        ON builds(repository_id, event_type, state, branch);
    SQL
  end

  def down
    execute "DROP INDEX index_builds_on_repository_id_and_event_type_and_state_and_branch"
  end
end
