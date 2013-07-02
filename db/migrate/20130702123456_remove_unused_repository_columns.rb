class RemoveUnusedRepositoryColumns < ActiveRecord::Migration
  def change
    remove_column :repository, :last_duration
    remove_column :repository, :last_build_status
    remove_column :repository, :last_build_result
    remove_column :repository, :last_build_language
  end
end
