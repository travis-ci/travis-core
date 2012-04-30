module Travis
  module Notifications
    module Json
      module Archive
        class Build
          class Test < Build
            class Job
              attr_reader :job, :commit

              def initialize(job)
                @job = job
                @commit = job.commit
              end

              def data
                {
                  'id' => job.id,
                  'number' => job.number,
                  'config' => job.config,
                  'started_at' => job.started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                  'finished_at' => job.finished_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                  'log' => job.log.content
                }
              end
            end

            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              {
                'id' => build.id,
                'number' => build.number,
                'config' => build.config.stringify_keys,
                'result' => 0,
                'started_at' => build.started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'finished_at' => build.finished_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'committed_at' => commit.committed_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'matrix' => build.matrix.map { |job| Job.new(job).data }
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug
              }
            end
          end
        end
      end
    end
  end
end


