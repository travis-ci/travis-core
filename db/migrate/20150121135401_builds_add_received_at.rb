class BuildsAddReceivedAt < ActiveRecord::Migration
  def change
    add_column :builds, :received_at, :datetime
  end
end
