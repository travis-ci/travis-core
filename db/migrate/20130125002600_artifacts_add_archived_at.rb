class ArtifactsAddArchivedAt < ActiveRecord::Migration
  def change
    add_column :artifacts, :archived_at, :datetime
    add_index :artifacts, :archived_at
  end
end
