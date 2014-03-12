class AddRemovalInfoToLogs < ActiveRecord::Migration
  def up
    add_column :logs, :removed_by, :integer
    add_column :logs, :removed_at, :datetime
    execute <<-SQL
      ALTER TABLE logs
        ADD CONSTRAINT logs_users_removed_by_fk
        FOREIGN KEY (removed_by)
        REFERENCES users(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE logs
        DROP CONSTRAINT logs_users_removed_by_fk
    SQL
    remove_column :logs, :removed_by
    remove_column :logs, :removed_at
  end
end
