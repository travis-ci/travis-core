class RemoveWorkersTableAndIndexes < ActiveRecord::Migration
  def up
    drop_table :workers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
