module Travis
  module Api
    module Json
      module Pusher
        class Build
          class Started < Build
            class Job
              attr_reader :job, :commit

              def initialize(job)
                @job = job
                @commit = job.commit
              end

              def data
                {
                  'id' => job.id,
                  'repository_id' => job.repository_id,
                  'parent_id' => job.source_id,
                  'number' => job.number,
                  'config' => job.config,
                  'commit' => commit.commit,
                  'branch' => commit.branch,
                  'message' => commit.message,
                  'compare_url' => commit.compare_url,
                  'committed_at' => commit.committed_at,
                  'author_name' => commit.author_name,
                  'author_email' => commit.author_email,
                  'committer_name' => commit.committer_name,
                  'committer_email' => commit.committer_email
                }
              end
            end

            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              {
                'id' => build.id,
                'repository_id' => build.repository_id,
                'number' => build.number,
                'config' => build.config.stringify_keys,
                'result' => 0,
                'started_at' => build.started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'compare_url' => commit.compare_url,
                'committed_at' => commit.committed_at,
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'event_type' => request.event_type,
                'matrix' => build.matrix.map { |job| Job.new(job).data }
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'description' => repository.description,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_started_at' => repository.last_build_started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'last_build_finished_at' => repository.last_build_finished_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'last_build_duration' => repository.last_build_duration,
                'last_build_result' => repository.last_build_status,
                'last_build_language' => repository.last_build_language
              }
            end
          end
        end
      end
    end
  end
end

