class JobsAddIndexOwnerId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_owner_id ON jobs (owner_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_jobs_on_owner_id"
  end
end
