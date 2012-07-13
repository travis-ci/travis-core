class RenameInSyncToIsSyncing < ActiveRecord::Migration
  def change
    rename_column :users, :in_sync, :is_syncing
  end
end
