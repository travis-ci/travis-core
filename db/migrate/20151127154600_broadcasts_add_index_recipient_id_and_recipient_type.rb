class BroadcastsAddIndexRecipientIdAndRecipientType < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_broadcasts_on_recipient_id_and_recipient_type ON broadcasts (recipient_id, recipient_type)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_broadcasts_on_recipient_id_and_recipient_type"
  end
end
