class IndexRequestsOnCreatedAt < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX IF EXISTS index_requests_on_created_at"
    execute "CREATE INDEX CONCURRENTLY index_requests_on_created_at ON requests(created_at)"
  end

  def down
    execute "DROP INDEX index_requests_on_created_at"
  end
end
