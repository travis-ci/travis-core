class JobsDropIndexTypeAndSourceIdAndSourceType < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_jobs_on_type_and_owner_id_and_owner_type"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_type_and_source_id_and_source_type ON jobs (type, source_id, source_type)"
  end
end
