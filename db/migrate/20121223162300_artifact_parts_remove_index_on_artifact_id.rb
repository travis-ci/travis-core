class ArtifactPartsRemoveIndexOnArtifactId < ActiveRecord::Migration
  def change
    remove_index :artifact_parts, :artifact_id
  end
end

