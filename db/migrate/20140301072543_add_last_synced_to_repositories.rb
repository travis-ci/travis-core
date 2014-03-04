class AddLastSyncedToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :last_sync, :timestamp
  end
end
