class AddIndexOnBuildState < ActiveRecord::Migration
  def up
     execute <<-SQL
      CREATE INDEX CONCURRENTLY index_builds_on_state
        ON builds(state);
    SQL
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_state"
  end
end
