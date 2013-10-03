module Travis
  module Api
    module V1
      module Http
        class Branch
          include Formats, Helpers::Legacy

          attr_reader :build, :options

          def initialize(build, options = {})
            @build = build
          end

          def cache_key
            "branch-#{build.id}"
          end

          def updated_at
            build.finished_at
          end

          def data
            {
              'repository_id' => build.repository_id,
              'build_id' => build.id,
              'commit' => build.commit.commit,
              'branch' => build.commit.branch,
              'message' => build.commit.message,
              'result' => legacy_build_result(build),
              'finished_at' => format_date(build.finished_at),
              'started_at' => format_date(build.started_at)
            }
          end
        end
      end
    end
  end
end
