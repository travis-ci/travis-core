class AddQueuedAtToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :queued_at, :datetime
  end
end

