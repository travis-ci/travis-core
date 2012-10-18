class AddEventTypeToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :event_type, :string
  end
end
