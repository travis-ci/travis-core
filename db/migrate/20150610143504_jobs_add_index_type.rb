class JobsAddIndexType < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_type ON jobs (type)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_type"
  end
end
