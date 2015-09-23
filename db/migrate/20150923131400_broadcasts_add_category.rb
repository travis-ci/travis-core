class BroadcastsAddCategory < ActiveRecord::Migration
  def change
    add_column :broadcasts, :category, :string
  end
end
