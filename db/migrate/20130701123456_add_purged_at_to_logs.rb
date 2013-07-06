class AddPurgedAtToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :purged_at, :timestamp
  end
end
