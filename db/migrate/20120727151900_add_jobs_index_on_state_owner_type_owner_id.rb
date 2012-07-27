class AddJobsIndexOnStateOwnerTypeOwnerId < ActiveRecord::Migration
  def change
    add_index :jobs, ['state', 'owner_id', 'owner_type'], :name => 'index_jobs_on_state_owner_type_owner_id'
  end
end
