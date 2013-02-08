class RenameArtifacts < ActiveRecord::Migration
  def change
    rename_table :artifacts, :artifacts_backup
    rename_table :artifact_parts, :artifact_parts_backup
  end
end

