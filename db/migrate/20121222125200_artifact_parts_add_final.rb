class ArtifactPartsAddFinal < ActiveRecord::Migration
  def change
    add_column :artifact_parts, :final, :boolean
    add_column :artifact_parts, :created_at, :timestamp
  end
end
