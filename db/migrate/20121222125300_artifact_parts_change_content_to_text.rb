class ArtifactPartsChangeContentToText < ActiveRecord::Migration
  def up
    change_column :artifact_parts, :content, :text
  end

  def down
    change_column :artifact_parts, :content, :string
  end
end

