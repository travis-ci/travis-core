module Travis
  module Api
    module V1
      module Pusher
        class Build
          class Started < Build
            autoload :Job, 'travis/api/v1/pusher/build/started/job'

            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              {
                'id' => build.id,
                'repository_id' => build.repository_id,
                'number' => build.number,
                'config' => build.obfuscated_config.stringify_keys,
                'result' => nil,
                'started_at' => format_date(build.started_at),
                'commit' => commit.commit,
                'commit_id' => commit.id,
                'branch' => commit.branch,
                'message' => commit.message,
                'compare_url' => commit.compare_url,
                'committed_at' => format_date(commit.committed_at),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'event_type' => request.event_type,
                'matrix' => build.matrix.map { |job| Job.new(job).data },
                'job_ids' => build.matrix.map(&:id),
                'state' => build.state.to_s
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'description' => repository.description,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_started_at' => format_date(repository.last_build_started_at),
                'last_build_finished_at' => format_date(repository.last_build_finished_at),
                'last_build_duration' => repository.last_build_duration,
                'last_build_status' => repository.last_build_result,
                'last_build_result' => repository.last_build_result,
                'last_build_language' => repository.last_build_language
              }
            end
          end
        end
      end
    end
  end
end

