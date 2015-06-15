class JobsDropIndexOwnerIdAndOwnerTypeAndState < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_jobs_on_owner_id_and_owner_type_and_state"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_owner_id_and_owner_type_and_state ON jobs (owner_id, owner_type, state)"
  end
end
