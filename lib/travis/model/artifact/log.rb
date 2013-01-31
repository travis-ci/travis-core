require 'metriks'

class Artifact::Log < Artifact
  include Travis::Event

  # TODO remove this once we know aggregation works fine and the worker passes a :final flag
  FINAL = 'Done. Build script exited with:'

  class << self
    def append(job_id, chars, number = nil, final = false)
      if Travis::Features.feature_active?(:log_aggregation)
        id = Artifact::Log.where(job_id: job_id).select(:id).first.id
        puts "[warn] artifact is is nil for job_id: #{job_id}, number: #{number}, ignoring the log part!" unless id
        meter('logs.update') do
          Artifact::Part.create!(artifact_id: id, content: filter(chars), number: number, final: final || final?(chars)) if id
        end
      else
        meter('logs.update') do
          update_all(["content = COALESCE(content, '') || ?", filter(chars)], ["job_id = ?", job_id])
        end
      end
    end

    def aggregate(id)
      ActiveRecord::Base.transaction do
        meter('logs.aggregate') do
          Artifact::Part.aggregate(id)
        end
        meter('logs.vacuum') do
          Artifact::Part.delete_all(artifact_id: id)
        end
        find(id).notify('aggregated')
      end
    end

    def aggregated_content(id)
      meter('logs.read_aggregated') do
        connection.select_value(sanitize_sql([Artifact::Part::AGGREGATE_SELECT_SQL, id])) || ''
      end
    end

    private

      def filter(chars)
        # postgres seems to have issues with null chars
        chars.gsub("\0", '')
      end

      def final?(chars)
        chars.include?(FINAL)
      end

      # TODO should be done by Travis::LogSubscriber::ActiveRecordMetrics but i can't get it
      # to be picked up outside of rails
      def meter(name, &block)
        Metriks.timer(name).time(&block)
      end
  end

  has_many :parts, class_name: 'Artifact::Part', foreign_key: :artifact_id

  def content
    if Travis::Features.feature_active?(:log_aggregation)
      content = read_attribute(:content) || ''
      content = [content, self.class.aggregated_content(id)].join unless aggregated?
      content
    else
      read_attribute(:content)
    end
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
