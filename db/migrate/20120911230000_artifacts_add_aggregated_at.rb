class ArtifactsAddAggregatedAt < ActiveRecord::Migration
  def change
    add_column :artifacts, :aggregated_at, :datetime
  end
end

