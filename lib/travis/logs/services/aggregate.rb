require 'active_support/core_ext/string/filters'

module Travis
  module Logs
    module Services
      class Aggregate < Travis::Services::Base
        register :logs_aggregate

        AGGREGATE_UPDATE_SQL = <<-sql.squish
          UPDATE artifacts
             SET aggregated_at = ?,
                 content = (COALESCE(content, '') || (#{Artifact::Log::AGGREGATE_PARTS_SELECT_SQL}))
           WHERE artifacts.id = ?
        sql

        AGGREGATEABLE_SELECT_SQL = <<-sql.squish
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
              connection.execute(sanitize_sql([AGGREGATE_UPDATE_SQL, Time.now, id, id]))
            end
          end

          def vacuum(id)
            meter('logs.vacuum') do
              Artifact::Part.delete_all(artifact_id: id)
            end
          end

          def notify(id)
            Artifact::Log.find(id).notify('aggregated')
          rescue ActiveRecord::RecordNotFound
            puts "[warn] could not find a log with the id #{id}"
          end

          def aggregateable_ids
            Artifact::Part.connection.select_values(query).map(&:to_i)
          end

          def query
            Artifact::Part.send(:sanitize_sql, [AGGREGATEABLE_SELECT_SQL, intervals[:regular], true, intervals[:force]])
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

          def connection
            Artifact::Part.connection
          end

          def sanitize_sql(*args)
            Artifact::Part.send(:sanitize_sql, *args)
          end
      end
    end
  end
end

