class AddIndexToBuildsRequestId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    # this will fail when running all migrations, so it needs to be applied
    # with rake db:migrate:up, which does not start transaction (contrary to db:migrate)
    execute "CREATE INDEX CONCURRENTLY index_builds_on_request_id ON builds(request_id)"
  end

  def down
    execute "DROP INDEX index_builds_on_request_id"
  end
end
