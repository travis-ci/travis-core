class AddIndexOnRepositoryIdAndEventTypeToBuilds < ActiveRecord::Migration
  def change
    add_index :builds, [:repository_id, :event_type]
  end
end
