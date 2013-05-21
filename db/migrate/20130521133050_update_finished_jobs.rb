class UpdateFinishedJobs < ActiveRecord::Migration
  def up
    execute "UPDATE jobs SET state = 'passed' WHERE state = 'finished' AND result = 0"
    execute "UPDATE jobs SET state = 'failed' WHERE state = 'finished' AND result = 1"
    count = execute("SELECT COUNT(*) FROM jobs WHERE state = 'finished'").first["count"].to_i
    raise "Finished jobs remaining" unless count == 0
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
