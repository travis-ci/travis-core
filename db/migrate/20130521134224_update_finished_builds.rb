class UpdateFinishedBuilds < ActiveRecord::Migration
  def up
    execute "UPDATE builds SET state = 'passed' WHERE state = 'finished' AND result = 0"
    execute "UPDATE builds SET state = 'failed' WHERE state = 'finished' AND result = 1"
    count = execute("SELECT COUNT(*) FROM builds WHERE state = 'finished'").first["count"].to_i
    raise "Finished builds remaining" unless count == 0
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
