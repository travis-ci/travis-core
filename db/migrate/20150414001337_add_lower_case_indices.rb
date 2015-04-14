class AddLowerCaseIndices < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    add_lower_index :organizations, :login
    add_lower_index :users,         :login
    add_lower_index :repositories,  :name
    add_lower_index :repositories,  :owner_name
  end

  def down
    drop_lower_index :organizations, :login
    drop_lower_index :users,         :login
    drop_lower_index :repositories,  :name
    drop_lower_index :repositories,  :owner_name
  end

  def add_lower_index(table, field)
    drop_lower_index(table, field)
    execute "CREATE INDEX CONCURRENTLY index_#{table}_on_lower_#{field} ON #{table} USING btree(lower(#{field}))"
  end

  def drop_lower_index(table, field)
    execute "DROP INDEX IF EXISTS index_#{table}_on_lower_#{field}"
  end
end
