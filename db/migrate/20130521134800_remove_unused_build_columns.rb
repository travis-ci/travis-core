class RemoveUnusedBuildColumns < ActiveRecord::Migration
  def change
    remove_column :builds, :result
    remove_column :builds, :status
    remove_column :builds, :previous_result
    remove_column :builds, :agent
    remove_column :builds, :language
    remove_column :builds, :archived_at
  end
end
