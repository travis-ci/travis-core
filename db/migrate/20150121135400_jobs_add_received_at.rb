class JobsAddReceivedAt < ActiveRecord::Migration
  def change
    add_column :jobs, :received_at, :datetime
  end
end
