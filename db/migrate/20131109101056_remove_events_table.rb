class RemoveEventsTable < ActiveRecord::Migration
  def up
    drop_table :events
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
