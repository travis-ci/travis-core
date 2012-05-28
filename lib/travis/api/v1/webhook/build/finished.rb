module Travis
  module Api
    module V1
      module Webhook
        class Build
          class Finished < Build
            autoload :Job, 'travis/api/v1/webhook/build/finished/job'

            include Formats

            def data(options = {})
              {
                'id' => build.id,
                'repository' => repository_data,
                'number' => build.number,
                'config' => build.config.stringify_keys,
                'status' => build.result,
                'result' => build.result,
                'status_message' => build.result_message(build),
                'result_message' => build.result_message(build),
                'started_at' => format_date(build.started_at),
                'finished_at' => format_date(build.finished_at),
                'duration' => build.duration,
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'compare_url' => commit.compare_url,
                'committed_at' => format_date(commit.committed_at),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'matrix' => build.matrix.map { |job| Job.new(job).data(options) }
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'name' => repository.name,
                'owner_name' => repository.owner_name,
                'url' => repository.url
              }
            end
          end
        end
      end
    end
  end
end
