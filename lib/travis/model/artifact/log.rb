require 'metriks'

class Artifact::Log < Artifact
  include Travis::Event

  class << self
    def aggregated_content(id)
      Metriks.timer('logs.read_aggregated').time do
        connection.select_value(sanitize_sql([Artifact::Part::AGGREGATE_SELECT_SQL, id])) || ''
      end
    end
  end

  has_many :parts, class_name: 'Artifact::Part', foreign_key: :artifact_id

  def content
    content = read_attribute(:content) || ''
    content = [content, self.class.aggregated_content(id)].join unless aggregated?
    content
  end

  def aggregated?
    !!aggregated_at
  end

  def clear!
    update_attributes!(aggregated_at: nil, archived_at: nil, archive_verified: nil)
    update_column(:content, '')        # TODO why in the world does update_attributes not set content to ''
    update_column(:aggregated_at, nil) # TODO why in the world does update_attributes not set aggregated_at to nil?
    parts.delete_all
  end

  def archived?
    archived_at && archive_verified?
  end
end
