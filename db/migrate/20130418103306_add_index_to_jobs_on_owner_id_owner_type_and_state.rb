class AddIndexToJobsOnOwnerIdOwnerTypeAndState < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    # this will fail when running all migrations, so it needs to be applied
    # with rake db:migrate:up, which does not start transaction (contrary to db:migrate)
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_owner_id_and_owner_type_and_state ON jobs(owner_id, owner_type, state)"
  end

  def down
    execute "DROP INDEX index_jobs_on_owner_id_and_owner_type_and_state"
  end
end
