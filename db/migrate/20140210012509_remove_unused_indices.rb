class RemoveUnusedIndices < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY index_commits_on_commit"
    execute "DROP INDEX CONCURRENTLY index_builds_on_state"
    execute "DROP INDEX CONCURRENTLY index_commits_on_branch"
    execute "DROP INDEX CONCURRENTLY index_users_on_github_oauth_token"
    execute "DROP INDEX CONCURRENTLY index_builds_on_finished_at"
    execute "DROP INDEX CONCURRENTLY index_jobs_on_queue_and_state"
    execute "DROP INDEX CONCURRENTLY index_jobs_on_created_at"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY index_commits_on_commit ON commits(commit)"
    execute "CREATE INDEX CONCURRENTLY index_commits_on_commit ON builds(state)"
    execute "CREATE INDEX CONCURRENTLY index_commits_on_commit ON commits(branch)"
    execute "CREATE INDEX CONCURRENTLY index_commits_on_commit ON users(github_oauth_token)"
    execute "CREATE INDEX CONCURRENTLY index_builds_on_finshed_at ON builds(finished_at)"
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_queue_and_state ON jobs(queue, state)"
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_created_at ON jobs(created_at)"
  end
end
