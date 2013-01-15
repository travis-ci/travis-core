class AddIndexOnLastSeenAtToWorkers < ActiveRecord::Migration
  def change
    add_index :workers, :last_seen_at
  end
end
