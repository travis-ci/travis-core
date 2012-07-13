class AddSyncInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :in_sync, :boolean
    add_column :users, :synced_at, :timestamp
  end
end
