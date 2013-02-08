class DropArtifacts < ActiveRecord::Migration
  def change
    drop_table :artifacts_backup
    drop_table :artifact_parts_backup
  end
end

