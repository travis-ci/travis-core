class TokensAddIndexUserId < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_tokens_on_user_id ON tokens (user_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_tokens_on_user_id"
  end
end
