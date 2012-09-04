module Travis
  module Api
    module V1
      module Http
        class Branches
          include Formats

          attr_reader :repository, :options

          def initialize(repository, options = {})
            @repository = repository
          end

          def cache_key
            "#{r.id}-#{r.last_build_id}-branches"
          end

          def updated_at
            repository.last_build_finished_at
          end

          def data
            repository.last_finished_builds_by_branches.map do |build|
              {
                'repository_id' => build.repository_id,
                'build_id' => build.id,
                'commit' => build.commit.commit,
                'branch' => build.commit.branch,
                'message' => build.commit.message,
                'result' => build.result,
                'finished_at' => format_date(build.finished_at),
                'started_at' => format_date(build.started_at)
              }
            end
          end
        end
      end
    end
  end
end
