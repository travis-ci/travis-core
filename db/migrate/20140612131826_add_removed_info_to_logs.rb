class AddRemovedInfoToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :removed_at, :timestamp
    add_column :logs, :removed_by, :integer
  end
end
