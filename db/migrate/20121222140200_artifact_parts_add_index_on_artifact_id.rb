class ArtifactPartsAddIndexOnArtifactId < ActiveRecord::Migration
  def change
    add_index :artifact_parts, :artifact_id
  end
end

