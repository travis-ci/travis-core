class UpdateFinishedJobs < ActiveRecord::Migration
  def up
    execute "UPDATE jobs SET state = 'passed' WHERE state = 'finished' AND result = 0 AND type = 'Job::Test'"
    execute "UPDATE jobs SET state = 'failed' WHERE state = 'finished' AND result = 1 AND type = 'Job::Test'"
    execute "UPDATE jobs SET state = 'errored' WHERE state = 'finished' AND result IS NULL AND type = 'Job::Test'"
    count = execute("SELECT COUNT(*) FROM jobs WHERE state = 'finished' AND type = 'Job::Test'").first["count"].to_i
    raise "Finished jobs remaining" unless count == 0
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
