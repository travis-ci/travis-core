module Travis
  module Api
    module V1
      module Pusher
        class Build
          class Started < Build
            class Job
              include Formats

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
                  'config' => job.obfuscated_config,
                  'state' => job.finished? ? 'finished' : job.state.to_s,
                  'commit' => commit.commit,
                  'branch' => commit.branch,
                  'message' => commit.message,
                  'compare_url' => commit.compare_url,
                  'started_at' => format_date(job.started_at),
                  'finished_at' => format_date(job.finished_at),
                  'committed_at' => format_date(commit.committed_at),
                  'author_name' => commit.author_name,
                  'author_email' => commit.author_email,
                  'committer_name' => commit.committer_name,
                  'committer_email' => commit.committer_email,
                  'allow_failure' => job.allow_failure
                }
              end
            end
          end
        end
      end
    end
  end
end
