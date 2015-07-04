class ReposAddInvalidatedAt < ActiveRecord::Migration
  def change
    add_column :repositories, :invalidated_at, :datetime
  end
end
