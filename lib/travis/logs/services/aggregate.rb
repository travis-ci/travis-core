module Travis
  module Logs
    module Services
      class Aggregate < Travis::Services::Base
        register :logs_aggregate

        QUERY = %(
          SELECT DISTINCT artifact_id
            FROM artifact_parts
           WHERE created_at <= NOW() - interval '? seconds' AND final = ?
              OR created_at <= NOW() - interval '? seconds'
        )

        def run
          return unless active?
          aggregateable_log_ids.each do |id|
            Artifact::Log.aggregate(id)
          end
        end

        private

          def active?
            Travis::Features.feature_active?(:log_aggregation)
          end

          def aggregateable_log_ids
            Artifact::Part.connection.select_values(query).map(&:to_i)
          end

          def query
            Artifact::Part.send(:sanitize_sql, [QUERY, intervals[:regular], true, intervals[:force]])
          end

          def intervals
            Travis.config.logs.intervals
          end
      end
    end
  end
end

