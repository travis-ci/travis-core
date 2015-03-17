class AddTokenIndexToTokens < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "DROP INDEX IF EXISTS index_tokens_on_token"
    execute "CREATE INDEX CONCURRENTLY index_tokens_on_token ON tokens(token)"
  end

  def down
    execute "DROP INDEX IF EXISTS index_tokens_on_token"
  end
end
