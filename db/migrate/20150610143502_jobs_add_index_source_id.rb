class JobsAddIndexSourceId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_source_id ON jobs (source_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_source_id"
  end
end
