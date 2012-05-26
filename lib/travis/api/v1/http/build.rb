module Travis
  module Api
    module V1
      module Http
        class Build
          autoload :Job, 'travis/api/v1/http/build/job'

          include Formats

          attr_reader :build, :commit, :request

          def initialize(build, options = {})
            @build = build
            @commit = build.commit
            @request = build.request
          end

          def data
            {
              'id' => build.id,
              'repository_id' => build.repository_id,
              'number' => build.number,
              'config' => build.config.stringify_keys,
              'state' => build.state.to_s,
              'result' => build.result,
              'status' => build.result,
              'started_at' => format_date(build.started_at),
              'finished_at' => format_date(build.finished_at),
              'duration' => build.duration,
              'commit' => commit.commit,
              'branch' => commit.branch,
              'message' => commit.message,
              'committed_at' => format_date(commit.committed_at),
              'author_name' => commit.author_name,
              'author_email' => commit.author_email,
              'committer_name' => commit.committer_name,
              'committer_email' => commit.committer_email,
              'compare_url' => commit.compare_url,
              'event_type' => request.event_type,
              'matrix' => build.matrix.map { |job| Job.new(job).data },
            }
          end
        end
      end
    end
  end
end
