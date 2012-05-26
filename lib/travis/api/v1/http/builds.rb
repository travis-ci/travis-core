module Travis
  module Api
    module V1
      module Http
        class Builds
          include Formats

          attr_reader :builds

          def initialize(builds, options = {})
            @builds = builds
          end

          def data
            builds.map { |build| build_data(build) }
          end

          def build_data(build)
            commit = build.commit
            request = build.request
            {
              'id' => build.id,
              'repository_id' => build.repository_id,
              'number' => build.number,
              'state' => build.state.to_s,
              'result' => build.result,
              'started_at' => format_date(build.started_at),
              'finished_at' => format_date(build.finished_at),
              'duration' => build.duration,
              'commit' => commit.commit,
              'branch' => commit.branch,
              'message' => commit.message,
              'event_type' => request.event_type,
            }
          end
        end
      end
    end
  end
end
