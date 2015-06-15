class JobsAddIndexState < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_state ON jobs (state)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_state"
  end
end

