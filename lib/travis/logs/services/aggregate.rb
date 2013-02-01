require 'active_support/core_ext/string/filters'

module Travis
  module Logs
    module Services
      class Aggregate < Travis::Services::Base
        register :logs_aggregate

        SQL = <<-sql.squish
          SELECT DISTINCT artifact_id
            FROM artifact_parts
           WHERE created_at <= NOW() - interval '? seconds' AND final = ?
              OR created_at <= NOW() - interval '? seconds'
        sql

        def run
          return unless active?
          aggregateable_ids.each do |id|
            transaction do
              aggregate(id)
              vacuum(id)
              notify(id)
            end
          end
        end

        private

          def active?
            Travis::Features.feature_active?(:log_aggregation)
          end

          def aggregate(id)
            meter('logs.aggregate') do
              Artifact::Part.aggregate(id)
            end
          end

          def vacuum(id)
            meter('logs.vacuum') do
              Artifact::Part.delete_all(artifact_id: id)
            end
          end

          def notify(id)
            Artifact::Log.find(id).notify('aggregated')
          end

          def aggregateable_ids
            Artifact::Part.connection.select_values(query).map(&:to_i)
          end

          def query
            Artifact::Part.send(:sanitize_sql, [SQL, intervals[:regular], true, intervals[:force]])
          end

          def intervals
            Travis.config.logs.intervals
          end

          def transaction(&block)
            ActiveRecord::Base.transaction(&block)
          rescue ActiveRecord::ActiveRecordError => e
            # puts e.message, e.backtrace
            Travis::Exceptions.handle(e)
          end

          def meter(name, &block)
            Metriks.timer(name).time(&block)
          end
      end
    end
  end
end

