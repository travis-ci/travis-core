class Artifact::Part < ActiveRecord::Base
  self.table_name = 'artifact_parts'

  validates :artifact_id, presence: true, numericality: { greater_than: 0 }
end
