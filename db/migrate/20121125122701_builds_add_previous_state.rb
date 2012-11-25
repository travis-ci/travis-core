class BuildsAddPreviousState < ActiveRecord::Migration
  def change
    add_column :builds, :previous_state, :string
  end
end
