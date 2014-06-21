class AddRemovedInfoToLogs < ActiveRecord::Migration
  def change
    # These columns are needed for travis-core specs as well as enterprise, but may conflict
    # with migrations in travis-logs
    c = ActiveRecord::Base.connection
    return unless c.table_exists?(:logs)
    add_column :logs, :removed_at, :timestamp unless c.column_exists?(:logs, :removed_at)
    add_column :logs, :removed_by, :integer   unless c.column_exists?(:logs, :removed_by)
  end
end
