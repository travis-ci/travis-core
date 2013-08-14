class AddCanceledAtToJobsAndBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :canceled_at, :datetime
    add_column :jobs, :canceled_at, :datetime
  end
end
